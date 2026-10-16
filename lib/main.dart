import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/hook_screen.dart';
import 'screens/waiver_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/main_shell.dart';
import 'models/subscription_state.dart';
import 'services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize RevenueCat
  await Purchases.setLogLevel(LogLevel.debug);
  await Purchases.configure(
    PurchasesConfiguration('appl_wLMSomVpuKbkFvrmfPMxZTXFNzO'),
  );

  runApp(const GetFit4MeApp());
}

class GetFit4MeApp extends StatelessWidget {
  const GetFit4MeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GetFit4Me',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: const _RootRouter(),
    );
  }
}

/// Decides which top-level screen to show based on onboarding progress,
/// auth state, and subscription status. Onboarding flags (hook/waiver
/// seen) are intentionally kept local — they're a one-time first-run
/// experience, not something that needs to sync across devices. Auth and
/// subscription state, by contrast, come from Firebase so they're
/// consistent everywhere the user signs in.
class _RootRouter extends StatefulWidget {
  const _RootRouter();

  @override
  State<_RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<_RootRouter> {
  bool _hookSeen = false;
  bool _waiverAccepted = false;

  @override
  Widget build(BuildContext context) {
    if (!_hookSeen) {
      return HookScreen(onContinue: () => setState(() => _hookSeen = true));
    }
    if (!_waiverAccepted) {
      return WaiverScreen(onAccepted: () => setState(() => _waiverAccepted = true));
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _SplashLoader();
        }
        if (!authSnapshot.hasData) {
          return const AuthScreen();
        }

        // Signed in — now check subscription status from Firestore.
        return StreamBuilder<dynamic>(
          stream: FirestoreService().watchUserProfile(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _SplashLoader();
            }

            final data = profileSnapshot.data?.data() as Map<String, dynamic>?;
            final sub = SubscriptionState.fromFirestore(data);

            if (!sub.isActive) {
              return PaywallScreen(sub: sub);
            }
            return MainShell(sub: sub);
          },
        );
      },
    );
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5))),
    );
  }
}