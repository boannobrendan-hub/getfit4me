import * as functions from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import Stripe from "stripe";
import paypal from "@paypal/checkout-server-sdk";

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

// ── Secrets ──────────────────────────────────────────────────────────────
// Set these with:
//   firebase functions:secrets:set STRIPE_SECRET_KEY
//   firebase functions:secrets:set PAYPAL_CLIENT_ID
//   firebase functions:secrets:set PAYPAL_CLIENT_SECRET
// Never commit real values to source control.
const STRIPE_SECRET_KEY = process.env.STRIPE_SECRET_KEY ?? "";
const PAYPAL_CLIENT_ID = process.env.PAYPAL_CLIENT_ID ?? "";
const PAYPAL_CLIENT_SECRET = process.env.PAYPAL_CLIENT_SECRET ?? "";
const PAYPAL_ENV = process.env.PAYPAL_ENV ?? "sandbox"; // "sandbox" | "live"

const stripeClient = new Stripe(STRIPE_SECRET_KEY, { apiVersion: "2024-09-30.acacia" });

function paypalClient() {
  const env =
    PAYPAL_ENV === "live"
      ? new paypal.core.LiveEnvironment(PAYPAL_CLIENT_ID, PAYPAL_CLIENT_SECRET)
      : new paypal.core.SandboxEnvironment(PAYPAL_CLIENT_ID, PAYPAL_CLIENT_SECRET);
  return new paypal.core.PayPalHttpClient(env);
}

// Plan catalogue — single source of truth for pricing on the backend.
// The Flutter app sends only a planId; it never sends a price, so a
// tampered client can't request a different amount than what's defined
// here.
const PLAN_PRICES: Record<string, { amountUsd: number; days: number; label: string }> = {
  weekly: { amountUsd: 15, days: 7, label: "1-Week Access" },
  monthly: { amountUsd: 35, days: 30, label: "1-Month Access" },
  yearly: { amountUsd: 285, days: 365, label: "1-Year Access" },
};

function requireAuth(request: functions.CallableRequest) {
  if (!request.auth) {
    throw new functions.HttpsError("unauthenticated", "You must be signed in.");
  }
  return request.auth.uid;
}

function requirePlan(planId: unknown) {
  if (typeof planId !== "string" || !(planId in PLAN_PRICES)) {
    throw new functions.HttpsError("invalid-argument", "Unknown or missing planId.");
  }
  return PLAN_PRICES[planId];
}

// ── Stripe ───────────────────────────────────────────────────────────────

export const createStripePaymentIntent = functions.onCall(
  { secrets: ["STRIPE_SECRET_KEY"] },
  async (request) => {
    const uid = requireAuth(request);
    const plan = requirePlan(request.data?.planId);

    const intent = await stripeClient.paymentIntents.create({
      amount: Math.round(plan.amountUsd * 100), // Stripe uses the smallest currency unit (cents)
      currency: "usd",
      metadata: { uid, planId: request.data.planId },
      automatic_payment_methods: { enabled: true },
    });

    return { clientSecret: intent.client_secret };
  }
);

// Stripe webhook — the SOURCE OF TRUTH for subscription activation. Stripe
// calls this directly; it does not go through the callable-function auth
// flow above. Configure this URL in the Stripe dashboard's webhook
// settings, and set the signing secret via:
//   firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
export const stripeWebhook = functions.onRequest(
  { secrets: ["STRIPE_SECRET_KEY", "STRIPE_WEBHOOK_SECRET"] },
  async (req, res) => {
    const sig = req.headers["stripe-signature"] as string;
    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET ?? "";

    let event: Stripe.Event;
    try {
      event = stripeClient.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
    } catch (err) {
      logger.error("Stripe webhook signature verification failed", err);
      res.status(400).send("Invalid signature");
      return;
    }

    if (event.type === "payment_intent.succeeded") {
      const intent = event.data.object as Stripe.PaymentIntent;
      const uid = intent.metadata.uid;
      const planId = intent.metadata.planId;
      const plan = PLAN_PRICES[planId];

      if (uid && plan) {
        const expiresAt = admin.firestore.Timestamp.fromDate(
          new Date(Date.now() + plan.days * 24 * 60 * 60 * 1000)
        );
        await db.collection("users").doc(uid).set(
          { subscriptionPlan: planId, subscriptionExpiresAt: expiresAt },
          { merge: true }
        );
        logger.info(`Activated ${planId} for user ${uid} via Stripe`);
      }
    }

    res.status(200).send("ok");
  }
);

// ── PayPal ───────────────────────────────────────────────────────────────

export const createPaypalOrder = functions.onCall(
  { secrets: ["PAYPAL_CLIENT_ID", "PAYPAL_CLIENT_SECRET"] },
  async (request) => {
    const uid = requireAuth(request);
    const planId = request.data?.planId as string;
    const plan = requirePlan(planId);

    const order = new paypal.orders.OrdersCreateRequest();
    order.requestBody({
      intent: "CAPTURE",
      purchase_units: [
        {
          reference_id: `${uid}_${planId}_${Date.now()}`,
          amount: { currency_code: "USD", value: plan.amountUsd.toFixed(2) },
          description: `GetFit4Me — ${plan.label}`,
          custom_id: JSON.stringify({ uid, planId }),
        },
      ],
      application_context: {
        // Must match the prefixes checked in PaypalWebviewScreen.
        return_url: "https://getfit4me.app/paypal-return",
        cancel_url: "https://getfit4me.app/paypal-cancel",
        brand_name: "GetFit4Me",
        user_action: "PAY_NOW",
      },
    });

    const response = await paypalClient().execute(order);
    const approvalUrl = response.result.links.find((l: any) => l.rel === "approve")?.href;

    return { orderId: response.result.id, approvalUrl };
  }
);

export const capturePaypalOrder = functions.onCall(
  { secrets: ["PAYPAL_CLIENT_ID", "PAYPAL_CLIENT_SECRET"] },
  async (request) => {
    const uid = requireAuth(request);
    const orderId = request.data?.orderId as string;
    if (!orderId) {
      throw new functions.HttpsError("invalid-argument", "Missing orderId.");
    }

    const captureRequest = new paypal.orders.OrdersCaptureRequest(orderId);
    (captureRequest as any).requestBody({});
    const response = await paypalClient().execute(captureRequest);

    const customIdRaw = response.result.purchase_units?.[0]?.payments?.captures?.[0]?.custom_id
      ?? response.result.purchase_units?.[0]?.custom_id;

    let planId: string | undefined;
    try {
      const parsed = JSON.parse(customIdRaw ?? "{}");
      planId = parsed.planId;
      // Defense in depth: confirm the order actually belongs to the calling user.
      if (parsed.uid !== uid) {
        throw new functions.HttpsError("permission-denied", "Order does not belong to this user.");
      }
    } catch {
      throw new functions.HttpsError("internal", "Could not read order metadata.");
    }

    const plan = planId ? PLAN_PRICES[planId] : undefined;
    const success = response.result.status === "COMPLETED" && !!plan;

    if (success && plan && planId) {
      const expiresAt = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + plan.days * 24 * 60 * 60 * 1000)
      );
      await db.collection("users").doc(uid).set(
        { subscriptionPlan: planId, subscriptionExpiresAt: expiresAt },
        { merge: true }
      );
      logger.info(`Activated ${planId} for user ${uid} via PayPal`);
    }

    return { success, plan: planId };
  }
);
