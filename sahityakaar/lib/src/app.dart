import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/not_found.dart';
import 'screens/index_screen.dart';
import 'providers/auth_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Sahityakaar',
      theme: appTheme,
      home: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (user) {
          // If no user session, show index page
          if (user == null) {
            return const IndexScreen();
          }
          // If user session exists, show home page
          return const HomeScreen();
        },
      ),
      onGenerateRoute: (settings) {
        // Protect routes that require authentication
        final authState = ref.read(authProvider);
        final isAuthenticated = authState.value != null;

        return MaterialPageRoute(
          builder: (context) {
            switch (settings.name) {
              case '/':
                return isAuthenticated ? const HomeScreen() : const IndexScreen();
              case '/login':
                return isAuthenticated ? const HomeScreen() : const LoginScreen();
              case '/profile':
                // Redirect to login if trying to access protected routes while unauthenticated
                return isAuthenticated ? const ProfileScreen() : const LoginScreen();
              default:
                return const NotFoundScreen();
            }
          },
        );
      },
    );
  }
}