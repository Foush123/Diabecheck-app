import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const String routeName = '/welcome';
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset('lib/assets/images/logo.png', height: 90),
              const SizedBox(height: 24),
              Text(
                "Let's get started!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                "Login to enjoy the features we've provided, and stay healthy!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: const StadiumBorder(),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                  ),
                  
                  onPressed: () => Navigator.of(context).pushNamed(LoginScreen.routeName),
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: const StadiumBorder(),
                    side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => Navigator.of(context).pushNamed(SignupScreen.routeName),
                  child: const Text('Sign Up'),
                ),
              ),
              const SizedBox(height: 185),
            ],
          ),
        ),
      ),
    );
  }
}


