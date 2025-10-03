// api_key_provider.dart
import 'package:flutter/services.dart';

class ApiKeyProvider {
  static const platform = MethodChannel('com.sot/app');

  static Future<String> getGoogleMapsApiKey() async {
    try {
      final String key = await platform.invokeMethod('getGoogleMapsApiKey');
      return key;
    } on PlatformException catch (e) {
      print('Failed to get API key: ${e.message}');
      return '';
    }
  }
}