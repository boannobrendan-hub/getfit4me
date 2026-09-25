import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles all persisted user data: profile, subscription status, completed
/// workout timestamps (drives the trophy system), and post-workout
/// feedback history. Replaces the DartPad prototype's in-memory lists,
/// which reset on every restart.
///
/// Firestore structure:
///   users/{uid}                        — profile fields, subscription status
///   users/{uid}/completions/{auto-id}   — one doc per finished workout
///   users/{uid}/feedback/{auto-id}      — one doc per feedback submission
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> get _userDoc {
    final uid = _uid;
    if (uid == null) throw StateError('No authenticated user.');
    return _db.collection('users').doc(uid);
  }

  /// Call once right after a successful sign-up to create the user's
  /// profile document with sensible defaults.
  Future<void> createUserProfile({required String email}) async {
    await _userDoc.set({
      'email': email,
      'profileEmoji': '💪',
      'createdAt': FieldValue.serverTimestamp(),
      'subscriptionPlan': 'none',
      'subscriptionExpiresAt': null,
      'trialUsed': false,
      'selectedSport': 'Basketball',
      'selectedCondition': 'Rheumatoid Arthritis',
      'isSportMode': true,
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUserProfile() {
    return _userDoc.snapshots();
  }

  Future<void> updateProfileEmoji(String emoji) =>
      _userDoc.set({'profileEmoji': emoji}, SetOptions(merge: true));

  Future<void> updateSelection({required bool isSportMode, required String sport, required String condition}) =>
      _userDoc.set({
        'isSportMode': isSportMode,
        'selectedSport': sport,
        'selectedCondition': condition,
      }, SetOptions(merge: true));

  /// Called after a successful payment confirmation (see PaymentService).
  /// Cloud Functions also writes this server-side on webhook confirmation
  /// as the source of truth — this client-side write is for immediate UI
  /// responsiveness only and should never be trusted alone for access
  /// control (see firestore.rules).
  Future<void> updateSubscription({
    required String plan,
    required DateTime expiresAt,
    required bool trialUsed,
  }) =>
      _userDoc.set({
        'subscriptionPlan': plan,
        'subscriptionExpiresAt': Timestamp.fromDate(expiresAt),
        'trialUsed': trialUsed,
      }, SetOptions(merge: true));

  Future<void> recordWorkoutCompletion({required String activity}) async {
    await _userDoc.collection('completions').add({
      'activity': activity,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Used by the trophy system (daily/weekly/monthly/streak tiers).
  /// Firestore doesn't compute streaks server-side here for simplicity —
  /// we fetch recent completions and compute client-side, same logic as
  /// the DartPad prototype's `_computeTrophyStats`.
  Future<List<DateTime>> fetchCompletionTimestamps({int limit = 500}) async {
    final snap = await _userDoc
        .collection('completions')
        .orderBy('completedAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => (d.data()['completedAt'] as Timestamp?)?.toDate())
        .whereType<DateTime>()
        .toList();
  }

  Future<void> recordFeedback({
    required String activity,
    required int rating,
    required List<String> tags,
    required String note,
  }) async {
    await _userDoc.collection('feedback').add({
      'activity': activity,
      'rating': rating,
      'tags': tags,
      'note': note,
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Returns the most recent feedback entry matching `activity`, or null.
  /// Mirrors the DartPad prototype's `_feedbackHistory.firstWhere` lookup
  /// used to scale the next workout's intensity.
  Future<Map<String, dynamic>?> fetchMostRecentFeedbackFor(String activity) async {
    final snap = await _userDoc
        .collection('feedback')
        .where('activity', isEqualTo: activity)
        .orderBy('submittedAt', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data();
  }

  Future<List<Map<String, dynamic>>> fetchRecentFeedback({int limit = 5}) async {
    final snap = await _userDoc
        .collection('feedback')
        .orderBy('submittedAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }
}
