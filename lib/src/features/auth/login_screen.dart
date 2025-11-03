import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shell/shell_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(ShellScreen.routeName);
    } on FirebaseAuthException catch (e) {
      final message = _mapAuthError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email to reset password.')),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    } on FirebaseAuthException catch (e) {
      final message = _mapAuthError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return 'Authentication error: ${e.code}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const SizedBox(height: 8),
                _RoundedField(
                  controller: _email,
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                  prefix: const Icon(Icons.mail_outline),
                ),
                const SizedBox(height: 12),
                _RoundedField(
                  controller: _password,
                  hint: 'Enter your password',
                  obscureText: _obscure,
                  validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
                  prefix: const Icon(Icons.lock_outline),
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: _loading ? null : _resetPassword, child: const Text('Forgot Password?')),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: const StadiumBorder(),backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.surface,),
                  child: _loading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Login'),
                ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Don't have an account? "),
                  GestureDetector(onTap: () => Navigator.of(context).pushReplacementNamed('/signup'), child: Text('Sign Up', style: TextStyle(color: Theme.of(context).colorScheme.primary)))
                ]),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final Widget? prefix;
  final Widget? suffix;

  const _RoundedField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        prefixIcon: prefix,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
      ),
    );
  }
}


