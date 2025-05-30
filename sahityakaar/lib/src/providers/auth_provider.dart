import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider = StreamProvider<User?>((ref) {
  final client = Supabase.instance.client;

  return client.auth.onAuthStateChange.map((event) {
    switch (event.event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
      case AuthChangeEvent.initialSession:
        return event.session?.user;
      case AuthChangeEvent.signedOut:
        return null;
      default:
        return event.session?.user;
    }
  });
});
