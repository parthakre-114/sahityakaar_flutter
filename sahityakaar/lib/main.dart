import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/app.dart';
import 'src/utils/network_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Debug: Print environment variables to verify they're loaded
    final supabaseUrl = dotenv.env['EXPO_PUBLIC_SUPABASE_URL'];
    debugPrint('Supabase URL before processing: $supabaseUrl');

    if (supabaseUrl == null ||
        dotenv.env['EXPO_PUBLIC_SUPABASE_ANON_KEY'] == null) {
      throw Exception('Supabase environment variables are missing');
    }

    // Check network connectivity before proceeding
    final Uri uri = Uri.parse(supabaseUrl);
    final hasConnectivity = await NetworkUtils.checkHostConnectivity(uri.host);

    if (!hasConnectivity) {
      debugPrint(
        'No network connectivity to Supabase host. Please check your internet connection.',
      );
    }

    // Ensure URL uses HTTPS and has no trailing slash
    final processedUrl = supabaseUrl
        .replaceAll('http://', 'https://')
        .replaceAll(RegExp(r'/+$'), '');

    debugPrint('Processed Supabase URL: $processedUrl');

    // Initialize Supabase with persistent sessions
    await Supabase.initialize(
      url: processedUrl,
      anonKey: dotenv.env['EXPO_PUBLIC_SUPABASE_ANON_KEY']!,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
      debug: true,
    );

    debugPrint('Supabase initialized successfully with persistent session');
  } catch (e) {
    debugPrint('Error initializing app: $e');
    rethrow;
  }

  runApp(const ProviderScope(child: App()));
}
