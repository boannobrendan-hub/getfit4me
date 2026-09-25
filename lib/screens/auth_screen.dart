import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Production Sign Up / Sign In screen. Same UX as the DartPad prototype's
/// AuthScreen, but wired to real Firebase Authentication via AuthService
/// instead of an in-memory mock. Accounts persist across app restarts and
/// devices.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  bool _isSignUp = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  String? _errorText;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'Password is required';
    if (_isSignUp) {
      if (value.length < 8) return 'Use at least 8 characters';
      if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Include at least one uppercase letter';
      if (!RegExp(r'[0-9]').hasMatch(value)) return 'Include at least one number';
    }
    return null;
  }

  String? _validateConfirm(String? v) {
    if (!_isSignUp) return null;
    if (v != _passwordController.text) return "Passwords don't match";
    return null;
  }

  Future<void> _submit() async {
    setState(() => _errorText = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final error = _isSignUp
        ? await _authService.signUp(email: email, password: password)
        : await _authService.signIn(email: email, password: password);

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _submitting = false;
        _errorText = error;
      });
      return;
    }

    // On successful sign-up, create the Firestore profile doc with defaults.
    if (_isSignUp) {
      try {
        await _firestoreService.createUserProfile(email: email);
      } catch (_) {
        // Profile creation failure shouldn't block the user from proceeding —
        // FirestoreService calls elsewhere use SetOptions(merge: true) and
        // will create missing fields on first write anyway.
      }
    }

    if (!mounted) return;
    setState(() => _submitting = false);
    // No explicit navigation call needed here — the app root listens to
    // AuthService.authStateChanges and will rebuild into the next screen
    // automatically once Firebase Auth's state updates.
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || _validateEmail(email) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email above first, then tap "Forgot password?"')),
      );
      return;
    }
    final error = await _authService.sendPasswordResetEmail(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Password reset email sent — check your inbox.')),
    );
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _errorText = null;
      _confirmController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 12),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6)]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.fitness_center, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 24),
              Text(
                _isSignUp ? 'Create Your Account' : 'Welcome Back',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                _isSignUp ? "Let's set up your GetFit4Me account." : 'Sign in to pick up where you left off.',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
              ),
              const SizedBox(height: 32),
              _label('Email'),
              const SizedBox(height: 6),
              _darkField(
                controller: _emailController,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 18),
              _label('Password'),
              const SizedBox(height: 6),
              _darkField(
                controller: _passwordController,
                hint: _isSignUp ? 'At least 8 characters' : 'Your password',
                obscureText: _obscurePassword,
                validator: _validatePassword,
                suffix: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54, size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              if (_isSignUp) ...[
                const SizedBox(height: 18),
                _label('Confirm Password'),
                const SizedBox(height: 6),
                _darkField(
                  controller: _confirmController,
                  hint: 'Re-enter your password',
                  obscureText: _obscureConfirm,
                  validator: _validateConfirm,
                  suffix: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.white54, size: 20),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ],
              if (!_isSignUp) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    child: const Text('Forgot password?', style: TextStyle(color: Color(0xFF1DE9B6), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.withOpacity(0.4))),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorText!, style: const TextStyle(color: Colors.redAccent, fontSize: 12.5))),
                  ]),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text(
                          _isSignUp ? 'Create Account' : 'Sign In',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _toggleMode,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                      children: [
                        TextSpan(text: _isSignUp ? 'Already have an account? ' : "Don't have an account? "),
                        TextSpan(
                          text: _isSignUp ? 'Sign In' : 'Sign Up',
                          style: const TextStyle(color: Color(0xFF1DE9B6), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold));

  Widget _darkField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF1A2C3D),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF263545))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF263545))),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFF00BFA5), width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red.shade400)),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
      ),
    );
  }
}
