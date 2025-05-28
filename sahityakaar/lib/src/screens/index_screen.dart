import 'package:flutter/material.dart';
import '../../theme.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                ),
              ),

              const SizedBox(height: 24),

              // App Name
              Text(
                'Sahityakaar',
                style: theme.textTheme.titleLarge,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Where words come to life',
                style: theme.textTheme.bodyMedium,
              ),

              const Spacer(flex: 3),

              // Buttons
              SizedBox(
                width: double.infinity, // Make buttons full width
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('Register'),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
