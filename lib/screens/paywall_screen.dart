import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/subscription_state.dart';
import '../services/firestore_service.dart';

class PaywallScreen extends StatefulWidget {
  final SubscriptionState sub;
  const PaywallScreen({super.key, required this.sub});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final _firestoreService = FirestoreService();
  bool _processing = false;

  Future<void> _startTrial() async {
    if (widget.sub.trialUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your free trial has already been used.')));
      return;
    }
    setState(() => _processing = true);
    await _firestoreService.updateSubscription(
      plan: 'trial',
      expiresAt: DateTime.now().add(const Duration(days: 3)),
      trialUsed: true,
    );
    if (!mounted) return;
    setState(() => _processing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: Align(
              alignment: Alignment.topRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white24,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  minimumSize: const Size(44, 44),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('✕ Skip', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.fitness_center, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text('GetFit4Me', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 8),
                    const Text('4 coaches · 10 sports & 10 conditions', style: TextStyle(fontSize: 13, color: Color(0xFF78909C))),
                    const SizedBox(height: 40),
                    if (!widget.sub.trialUsed) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFA5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _processing ? null : _startTrial,
                          child: _processing
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Start 3-Day Free Trial', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('No credit card required', style: TextStyle(fontSize: 12, color: Color(0xFF78909C))),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFF263545)),
                      const SizedBox(height: 24),
                    ],
                    const Text('Already subscribed or want a paid plan?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    const Text('Visit our website to subscribe, then sign in here to access the full app.', style: TextStyle(fontSize: 13, color: Color(0xFF78909C)), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF00BFA5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final uri = Uri.parse('https://getfit4me.com');
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                        child: const Text('Subscribe at getfit4me.com', style: TextStyle(color: Color(0xFF00BFA5), fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Plans from \$15 · Cancel anytime', style: TextStyle(fontSize: 11, color: Color(0xFF546E7A))),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}