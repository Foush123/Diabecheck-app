import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'health_questionnaire_screen.dart';

class SignupScreen extends StatefulWidget {
  static const String routeName = '/signup';
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (_name.text.trim().isNotEmpty) {
        await cred.user?.updateDisplayName(_name.text.trim());
      }
      final user = cred.user;
      if (user != null) {
        try {
          final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
          await userDoc.set({
            'displayName': _name.text.trim(),
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Signed up, but profile save will retry later: $e')),
            );
          }
        }
      }
      if (!mounted) return;
      Navigator.of(context).pushNamed(HealthQuestionnaireScreen.routeName);
    } on FirebaseAuthException catch (e) {
      final message = _mapAuthError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up failed. Please try again.'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is disabled.';
      default:
        return 'Auth error: ${e.code}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: Builder(builder: (context) {
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
                  controller: _name,
                  hint: 'Enter your name',
                  validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                  prefix: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: const StadiumBorder(),backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.surface,),
                  child: _loading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Sign Up'),
                ),
                const SizedBox(height: 50),
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


