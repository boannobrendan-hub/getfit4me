import * as functions from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

/**
 * Called when a user taps "Alert Live Trainer" in the Support chat after
 * an urgent (emergency/severeDistress/crisis) message, or manually via
 * the persistent header button. This is the real backend counterpart to
 * the DartPad prototype's simulated "Connecting... -> Trainer Notified"
 * flow.
 *
 * WHAT THIS NEEDS BEFORE GOING LIVE:
 *   - An actual on-call trainer/clinical staffing system to page. Common
 *     options: PagerDuty/Opsgenie API call, Twilio SMS to an on-call
 *     rotation, or a dedicated internal dashboard your staff monitors.
 *     This function currently just writes a Firestore document a staff
 *     dashboard could read — wire in real paging before relying on it.
 *   - A clear internal SLA for how fast a human actually responds, and a
 *     fallback path (e.g., a follow-up automated message reminding the
 *     user to call 911) if no staff member acknowledges within N minutes.
 *   - Legal/clinical sign-off on what your staff is and isn't allowed to
 *     say or do when they respond, especially given this app is not a
 *     licensed telehealth service.
 */
export const alertLiveTrainer = functions.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.HttpsError("unauthenticated", "You must be signed in.");
  }
  const uid = request.auth.uid;
  const context = (request.data?.context as string) ?? "";
  const coachName = (request.data?.coachName as string) ?? "Unknown";

  const alertRef = await db.collection("liveTrainerAlerts").add({
    uid,
    coachName,
    context,
    status: "pending", // a staff dashboard would update this to "acknowledged" / "resolved"
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  logger.warn(`Live trainer alert created: ${alertRef.id} for user ${uid}`);

  // TODO (production): replace this log line with a real paging call, e.g.
  //   await pagerDutyClient.trigger({ summary: `GetFit4Me alert from ${uid}`, ... });
  // or an SMS via Twilio to your on-call trainer rotation.

  return { alertId: alertRef.id, status: "pending" };
});
