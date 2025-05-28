import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['EXPO_PUBLIC_SUPABASE_URL']!,
    anonKey: dotenv.env['EXPO_PUBLIC_SUPABASE_ANON_KEY']!,
  );

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

