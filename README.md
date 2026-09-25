# GetFit4Me — Flutter Production Project

This is the production Flutter project, migrated out of the DartPad
prototype. It uses real Firebase Authentication, Firestore, Cloud Functions,
and live Stripe + PayPal payment processing.

## ⚠️ Current build status

**Built and ready:**
- Project scaffold (`pubspec.yaml`, Firebase bootstrap, Firestore rules/indexes)
- `AuthService` + `AuthScreen` — real Firebase Auth sign up / sign in
- `FirestoreService` — user profile, subscription, completions, feedback
- `PaymentService` + `CheckoutScreen` + `PaypalWebviewScreen` — real Stripe
  PaymentSheet + PayPal webview approval flow
- Cloud Functions backend (`payments.ts`, `liveTrainerAlert.ts`) — Stripe
  PaymentIntents, Stripe webhook (source of truth for activation), PayPal
  order create/capture, live-trainer-alert stub
- `HookScreen`, `WaiverScreen`, `PaywallScreen` — ported from DartPad
- Data models: `Coach`, `CoachBrain` (full safety-tier chat logic),
  `SubscriptionState`, sport/condition exercise matrices, cross-reference
  tag data
- `ExerciseIllustration` widget — simplified single-pattern vector
  fallback (video-ready, see widget file header)
- `WorkoutFeedbackScreen` — post-workout rating/tags/notes
- **`MainShell`** — all 5 tabs fully built and wired to Firestore:
  - **Diagnostics**: sport/condition selection, cross-reference engine,
    energy/pain check-in, workout compilation with feedback-aware
    intensity scaling
  - **Engine**: live workout tracker with countdown timer, safety flags,
    scaled-intensity badge, cross-reference note, exercise illustration
  - **Support**: full CoachBrain-powered chat with safety-tier detection
    and an "Alert Live Trainer" flow
  - **Trophy Room**: tiered trophies (daily/weekly/monthly/streak),
    stats, recent feedback history
  - **Account**: avatar picker, plan management, coach switching, sign out

**This project should now `flutter run` successfully** once you complete
the one-time setup below (Firebase project credentials via
`flutterfire configure`, plus `flutter pub get`).

**Still NOT done — needed before shipping to real users:**
- Full 14-category detailed `ExerciseIllustration` painter (current
  version is a simplified single-pattern placeholder — functional, just
  less visually rich than the full set)
- Real Firebase project credentials (`lib/firebase_options.dart` still
  has placeholder values — run `flutterfire configure`)
- Real Stripe/PayPal API keys (`functions/` secrets, plus the
  `pk_live_REPLACE_ME` placeholder in `lib/main.dart`)
- Medical/PT professional review of the waiver, exercise matrices, and
  safety-keyword coverage in `CoachBrain`
- Apple/Google in-app purchase compliance review (see note in
  `lib/screens/paywall_screen.dart`) before submitting to the App
  Store / Play Store
- Filming and adding real exercise demo videos (see
  `assets/exercise_videos/PLACE_VIDEOS_HERE.txt`)
- Wiring the `alertLiveTrainer` Cloud Function call into
  `MainShell._alertLiveTrainer()` (currently simulated client-side with a
  TODO comment — the real Cloud Function exists and is ready to call)

## One-time setup

1. **Install Flutter** (3.24+) and run `flutter doctor` to confirm your
   environment is ready for iOS, Android, and Web targets.

2. **Create a Firebase project** at https://console.firebase.google.com.
   Enable:
   - Authentication → Email/Password sign-in method
   - Firestore Database (start in production mode)
   - Cloud Functions (requires upgrading to the Blaze pay-as-you-go plan —
     needed for outbound network calls to Stripe/PayPal from your functions)

3. **Run FlutterFire CLI** to generate `firebase_options.dart` automatically
   instead of hand-editing the placeholder in this project:
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This wires up iOS, Android, and Web automatically and replaces
   `lib/firebase_options.dart` with your real project's config.

4. **Install dependencies**:
   ```
   flutter pub get
   ```

5. **Deploy Cloud Functions** (after filling in your Stripe/PayPal secret
   keys — see `functions/README.md`):
   ```
   cd functions
   npm install
   firebase deploy --only functions
   ```

6. **Add your exercise videos** to `assets/exercise_videos/` and confirm the
   filenames match the map in `lib/widgets/exercise_illustration.dart`.

7. **Run the app**:
   ```
   flutter run
   ```

## Where things live

- `lib/services/auth_service.dart` — wraps Firebase Auth (sign up, sign in,
  sign out, auth state stream). Replaces the DartPad `_MockAuthStore`.
- `lib/services/payment_service.dart` — calls Cloud Functions to create
  Stripe PaymentIntents and PayPal orders. Never holds secret keys.
- `lib/services/firestore_service.dart` — reads/writes user profile,
  subscription status, feedback history, and completion timestamps.
- `lib/screens/` — same screens as the DartPad build, now wired to the
  services above instead of in-memory mocks.
- `functions/` — Node.js Cloud Functions: the only place Stripe/PayPal
  secret keys are used, and where the live-trainer alert would page a
  real on-call system.

## Security checklist before shipping

- [ ] Firestore security rules restrict each user to their own documents
      (`firestore.rules` included — review before deploying)
- [ ] Stripe/PayPal secret keys are stored as Cloud Functions config/secrets,
      never committed to source control or shipped in the app bundle
- [ ] App Check is enabled to reject requests from non-genuine app instances
- [ ] Apple/Google in-app purchase requirements reviewed for the
      subscription flow (see note in `lib/screens/paywall_screen.dart`)
