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
            mainAxisAlignment: MainAxisAlignment.center,
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

              const SizedBox(height: 16),

              // Divider line
              const Divider(
                color: Colors.black,
                thickness: 1,
                indent: 50,
                endIndent: 50,
              ),

              const SizedBox(height: 32),

              // Centered Buttons with adjusted width
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
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
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
