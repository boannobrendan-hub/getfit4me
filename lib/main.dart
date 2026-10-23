import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class _RootRouter extends StatefulWidget {
  const _RootRouter();

  @override
  State<_RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<_RootRouter> {
  bool _hookSeen = false;
  bool _waiverAccepted = false;
  bool _prefsLoaded = false;

  // Auth state: null = still loading, true = logged in, false = not logged in
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _initAuth();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hookSeen = prefs.getBool('hookSeen') ?? false;
      _waiverAccepted = prefs.getBool('waiverAccepted') ?? false;
      _prefsLoaded = true;
    });
  }

  void _initAuth() {
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() => _isLoggedIn = user != null);
      }
    });

    // Timeout: if Firebase Auth doesn't respond in 5 seconds, go to sign-in
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isLoggedIn == null) {
        setState(() => _isLoggedIn = false);
      }
    });
  }

  Future<void> _markHookSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hookSeen', true);
    setState(() => _hookSeen = true);
  }

  Future<void> _markWaiverAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('waiverAccepted', true);
    setState(() => _waiverAccepted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded) return const _SplashLoader();

    if (!_hookSeen) {
      return HookScreen(onContinue: _markHookSeen);
    }
    if (!_waiverAccepted) {
      return WaiverScreen(onAccepted: _markWaiverAccepted);
    }

    // Still waiting for Firebase Auth (max 5 seconds)
    if (_isLoggedIn == null) return const _SplashLoader();

    // Not logged in → show sign-in screen
    if (!_isLoggedIn!) return const AuthScreen();

    // Logged in → check subscription
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