import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionPlan { none, trial, weekly, monthly, yearly }

/// Mirrors the DartPad prototype's SubscriptionState, but now built from
/// Firestore data (synced via Cloud Functions on payment confirmation)
/// instead of held only in memory.
class SubscriptionState {
  final SubscriptionPlan plan;
  final DateTime? expiresAt;
  final bool trialUsed;

  const SubscriptionState({
    this.plan = SubscriptionPlan.none,
    this.expiresAt,
    this.trialUsed = false,
  });

  bool get isActive {
    if (plan == SubscriptionPlan.none) return false;
    if (expiresAt == null) return false;
    return expiresAt!.isAfter(DateTime.now());
  }

  String get planLabel {
    switch (plan) {
      case SubscriptionPlan.trial:
        return 'Free Trial';
      case SubscriptionPlan.weekly:
        return '1-Week Access';
      case SubscriptionPlan.monthly:
        return '1-Month Access';
      case SubscriptionPlan.yearly:
        return '1-Year Access';
      case SubscriptionPlan.none:
        return 'No Active Plan';
    }
  }

  String get daysRemaining {
    if (expiresAt == null) return 'No active plan';
    final days = expiresAt!.difference(DateTime.now()).inDays;
    if (days < 0) return 'Expired';
    if (days == 0) return 'Expires today';
    return '$days day${days == 1 ? '' : 's'} remaining';
  }

  factory SubscriptionState.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return const SubscriptionState();

    final planStr = data['subscriptionPlan'] as String? ?? 'none';
    final plan = SubscriptionPlan.values.firstWhere(
      (p) => p.name == planStr,
      orElse: () => SubscriptionPlan.none,
    );

    final expiresTimestamp = data['subscriptionExpiresAt'] as Timestamp?;

    return SubscriptionState(
      plan: plan,
      expiresAt: expiresTimestamp?.toDate(),
      trialUsed: data['trialUsed'] as bool? ?? false,
    );
  }
}
