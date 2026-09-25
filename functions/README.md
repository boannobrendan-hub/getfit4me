# GetFit4Me Cloud Functions

These functions hold the only secret keys in the entire system — the
Flutter app and DartPad prototype never see them.

## Setup

```
cd functions
npm install
```

## Required secrets

Set these via the Firebase CLI before deploying (never commit real values
to source control, and never put them in `.env` files that get bundled
into the app):

```
firebase functions:secrets:set STRIPE_SECRET_KEY
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
firebase functions:secrets:set PAYPAL_CLIENT_ID
firebase functions:secrets:set PAYPAL_CLIENT_SECRET
```

Also set, as a regular (non-secret) environment config value, which
PayPal environment to use:

```
firebase functions:config:set paypal.env="sandbox"
```//switch to "live" when ready for real transactions.

## Stripe webhook setup

1. Deploy functions once (`npm run deploy`) to get the `stripeWebhook`
   function's URL from the deploy output.
2. In the Stripe dashboard, go to Developers → Webhooks → Add endpoint,
   paste that URL, and subscribe to the `payment_intent.succeeded` event.
3. Copy the webhook's signing secret into
   `firebase functions:secrets:set STRIPE_WEBHOOK_SECRET`.

This webhook is the **source of truth** for activating a subscription —
the client-side Firestore write in `PaywallScreen` is only there for
immediate UI responsiveness and will be overwritten with the same
(correct) values moments later by this webhook.

## PayPal setup

1. Create an app at https://developer.paypal.com to get your Client ID
   and Secret (sandbox first, then a separate live app when ready).
2. Update the `return_url` / `cancel_url` in `src/payments.ts` to a real
   domain you control if `getfit4me.app` isn't yours — these are just
   placeholder URLs the webview watches for, they don't need to resolve
   to an actual working page since `PaypalWebviewScreen` intercepts the
   navigation before it loads.

## Local testing

```
npm run serve
```

This starts the Firebase emulator suite for functions. Point your Flutter
app at the emulator during development by calling
`FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001)`
early in `main()` (behind a debug-only flag).

## Deploying

```
npm run deploy
```

Requires the Blaze (pay-as-you-go) plan, since these functions make
outbound network calls to Stripe and PayPal.
