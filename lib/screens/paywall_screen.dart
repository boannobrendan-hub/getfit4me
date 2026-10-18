import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
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
  List<Package> _packages = [];
  String? _selectedPackageId;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current != null && mounted) {
        setState(() {
          _packages = current.availablePackages;
          // Default to monthly if available
          _selectedPackageId = current.monthly?.identifier ??
              (_packages.isNotEmpty ? _packages.first.identifier : null);
        });
      }
    } catch (e) {
      debugPrint('Error loading offerings: $e');
    }
  }

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

  Future<void> _purchaseSelected() async {
    if (_selectedPackageId == null || _packages.isEmpty) return;
    final pkg = _packages.firstWhere(
      (p) => p.identifier == _selectedPackageId,
      orElse: () => _packages.first,
    );
    setState(() => _processing = true);
    try {
      await Purchases.purchasePackage(pkg);
      final info = await Purchases.getCustomerInfo();
      final entitlement = info.entitlements.all['GetFit4Me Pro'];
      if (entitlement != null && entitlement.isActive) {
        await _firestoreService.updateSubscription(
          plan: pkg.packageType.name,
          expiresAt: DateTime.now().add(const Duration(days: 365)),
          trialUsed: widget.sub.trialUsed,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subscription activated! Welcome to GetFit4Me.')));
          Navigator.pop(context);
        }
      }
    } on PurchasesErrorCode catch (e) {
      if (e != PurchasesErrorCode.purchaseCancelledError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: ${e.name}')));
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _processing = true);
    try {
      final info = await Purchases.restorePurchases();
      final entitlement = info.entitlements.all['GetFit4Me Pro'];
      if (entitlement != null && entitlement.isActive && mounted) {
        await _firestoreService.updateSubscription(
          plan: 'restored',
          expiresAt: DateTime.now().add(const Duration(days: 365)),
          trialUsed: widget.sub.trialUsed,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase restored successfully!')));
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active subscription found to restore.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restore failed. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  String _labelForPackage(Package pkg) {
    switch (pkg.packageType) {
      case PackageType.weekly:
        return 'Weekly';
      case PackageType.monthly:
        return 'Monthly';
      case PackageType.annual:
        return 'Yearly';
      default:
        return pkg.identifier;
    }
  }

  String _badgeForPackage(Package pkg) {
    switch (pkg.packageType) {
      case PackageType.monthly:
        return 'MOST POPULAR';
      case PackageType.annual:
        return 'BEST VALUE';
      default:
        return '';
    }
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
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1A2C3D),
                      title: const Text('Subscription Required',
                        style: TextStyle(color: Colors.white)),
                      content: const Text(
                        'A subscription is required to use GetFit4Me. Start your 3-Day Free Trial or choose a plan below!',
                        style: TextStyle(color: Colors.grey)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('OK',
                            style: TextStyle(color: Color(0xFF00BFA5))),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('✕ Skip', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
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
                    const SizedBox(height: 32),

                    // Free Trial Button
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
                      const SizedBox(height: 8),
                      const Text('No credit card required', style: TextStyle(fontSize: 12, color: Color(0xFF78909C))),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFF263545)),
                      const SizedBox(height: 24),
                    ],

                    // Plan selector
                    if (_packages.isEmpty)
                      const CircularProgressIndicator(color: Color(0xFF00BFA5))
                    else ...[
                      const Text('Choose a Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 16),
                      ..._packages.map((pkg) {
                        final isSelected = _selectedPackageId == pkg.identifier;
                        final badge = _badgeForPackage(pkg);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPackageId = pkg.identifier),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF00BFA5) : const Color(0xFF263545),
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                color: isSelected ? const Color(0xFF0F2A3A) : const Color(0xFF111F2D),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: pkg.identifier,
                                    groupValue: _selectedPackageId,
                                    onChanged: (v) => setState(() => _selectedPackageId = v),
                                    activeColor: const Color(0xFF00BFA5),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(_labelForPackage(pkg),
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                            if (badge.isNotEmpty) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF00BFA5),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(pkg.storeProduct.priceString,
                                          style: const TextStyle(color: Color(0xFF00BFA5), fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFA5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _processing ? null : _purchaseSelected,
                          child: _processing
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Subscribe Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _processing ? null : _restorePurchases,
                        child: const Text('Restore Purchases', style: TextStyle(color: Color(0xFF78909C), fontSize: 13)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period. Manage in your Apple ID settings.',
                        style: TextStyle(fontSize: 10, color: Color(0xFF546E7A)),
                        textAlign: TextAlign.center,
                      ),
                    ],
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