import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final String url = dotenv.env['EXPO_PUBLIC_SUPABASE_URL']!;
  final String key = dotenv.env['EXPO_PUBLIC_SUPABASE_ANON_KEY']!;
  await Supabase.initialize(
    url: url,
    anonKey:key,
  );
  runApp(const MyApp());
}

  class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  return const MaterialApp(
  title: 'Users',
  home: HomePage(),
  );
  }
  }

  class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> {
  final Future<List<dynamic>> _future = Supabase.instance.client
      .from('users') // Change to 'instruments' if that's your table
      .select();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found.'));
          }
          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item['username'] ?? 'No Name'),
              );
            },
          );
        },
      ),
    );
  }
  }

