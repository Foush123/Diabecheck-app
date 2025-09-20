import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pushReplacementNamed(ShellScreen.routeName);
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
                  child: TextButton(onPressed: () {}, child: const Text('Forgot Password?')),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: const StadiumBorder(),backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.surface,),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Don't have an account? "),
                  GestureDetector(onTap: () => Navigator.of(context).pushReplacementNamed('/signup'), child: Text('Sign Up', style: TextStyle(color: Theme.of(context).colorScheme.primary)))
                ]),
                const SizedBox(height: 16),
                const _OrDivider(),
                const SizedBox(height: 16),
                const _SocialButton(icon: Icons.g_mobiledata, label: 'Sign in with Google'),
                const SizedBox(height: 12),
                const _SocialButton(icon: Icons.apple, label: 'Sign in with Apple'),
                const SizedBox(height: 12),
                const _SocialButton(icon: Icons.facebook, label: 'Sign in with Facebook'),
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(child: Divider()),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('OR', style: Theme.of(context).textTheme.labelMedium)),
      const Expanded(child: Divider()),
    ]);
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SocialButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 22),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
      ),
    );
  }
}


