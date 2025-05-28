// lib/widgets/supabase_test_widget.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Supabase extends StatefulWidget {
  const Supabase({Key? key}) : super(key: key);

  @override
  State<Supabase> createState() => _SupabaseState();
}

class _SupabaseState extends State<Supabase> {
  bool _loading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('users')         // pick any small table you have
          .select('uuid')
          .limit(1)
          .execute();

      if (response.error != null) {
        throw response.error!;
      }

      setState(() {
        _message = '✅ Supabase connected! Found ${response.data?.length ?? 0} user(s).';
      });
    } catch (error) {
      setState(() {
        _message = '❌ Supabase test failed:\n${error.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Supabase Connection Test',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (_loading)
              const CircularProgressIndicator()
            else if (_message != null)
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _message!.startsWith('✅') ? Colors.green : Colors.red,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Re-test'),
              onPressed: _testConnection,
            ),
          ],
        ),
      ),
    );
  }
}
