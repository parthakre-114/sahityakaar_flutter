import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkUtils {
  static Future<bool> checkHostConnectivity(String host) async {
    try {
      debugPrint('Attempting to resolve host: $host');

      // First try to ping a well-known public DNS to check general connectivity
      try {
        final result = await InternetAddress.lookup('8.8.8.8');
        if (result.isNotEmpty) {
          debugPrint('Successfully connected to Google DNS (8.8.8.8)');
        }
      } catch (e) {
        debugPrint('Failed to connect to Google DNS: $e');
        debugPrint('Device might not have internet connectivity');
      }

      // Now try to resolve our actual host
      final addresses = await InternetAddress.lookup(host);

      if (addresses.isEmpty) {
        debugPrint('No IP addresses found for $host');
        return false;
      }

      debugPrint('Resolved addresses for $host:');
      for (var addr in addresses) {
        debugPrint('  - ${addr.address} (${addr.type.name})');
      }

      // Try to connect to each resolved IP
      for (var address in addresses) {
        try {
          debugPrint('Testing connection to ${address.address}:443');
          final socket = await Socket.connect(
            address.address,
            443,
            timeout: const Duration(seconds: 5),
          );
          await socket.close();
          debugPrint('Successfully connected to ${address.address}:443');
          return true;
        } catch (e) {
          debugPrint('Failed to connect to ${address.address}: $e');
        }
      }

      return false;
    } catch (e) {
      debugPrint('DNS resolution failed for $host: $e');
      return false;
    }
  }
}
