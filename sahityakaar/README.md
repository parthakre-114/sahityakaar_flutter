# sahityakaar

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


 Typical Navigation / Workflow
App Launch (main.dart)

dotenv.load() → Supabase.initialize() → runApp(MyApp())

Router Setup (app.dart)

If no user session, route to /auth/login or /auth/register

Else, route to /home

Protected sub-routes redirect to login if authProvider says “unauthenticated”

Home Screen (home/home_screen.dart)

Shows your landing UI (logo, tagline, “Log In” / “Sign Up” buttons)

Tapping Log In → context.go('/auth/login')

Tapping Sign Up → context.go('/auth/register')

Auth Flow (auth/)

login_screen.dart / register_screen.dart handle form → call supabase.auth.signIn or signUp

On success → write session to Riverpod → navigate context.go('/profile')

Profile & Protected (profile/profile_screen.dart)

Display user data from authProvider.user

“Log Out” button calls supabase.auth.signOut() → state cleared → redirect to /auth/login

404 / Not Found

Any unknown route → show not_found.dart

