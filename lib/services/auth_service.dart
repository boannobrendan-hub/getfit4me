import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around Firebase Auth. Replaces the DartPad prototype's
/// in-memory `_MockAuthStore` with real, persisted, secure authentication.
///
/// Error messages are mapped to friendly strings so the UI layer can show
/// them directly without knowing about FirebaseAuthException codes.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Emits the current user (or null when signed out). The UI's root
  /// widget should listen to this to decide whether to show AuthScreen,
  /// the paywall, or the main app.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Returns null on success, or a friendly error message on failure.
  Future<String?> signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (_) {
      return 'Something went wrong. Please check your connection and try again.';
    }
  }

  /// Returns null on success, or a friendly error message on failure.
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (_) {
      return 'Something went wrong. Please check your connection and try again.';
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Returns null on success, or a friendly error message on failure.
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (_) {
      return 'Could not send reset email. Please try again.';
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Please choose a stronger password (at least 8 characters, with a number and an uppercase letter).';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
