// lib/core/utils/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.137.231:3000/api';  // Change based on your setup

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }
}