import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.100.34:3000/api';

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final user = FirebaseAuth.instance.currentUser;

    // 1. Force refresh the token to ensure it isn't expired
    final String? token = await user?.getIdToken(true);

    // 2. We must use "Bearer " (with a space) to match your backend split logic
    final String authValue = "Bearer $token";

    print('Debug: Sending request to $endpoint');
    // Optional: print(authValue); // Only for local debugging to verify "Bearer <long_string>"

    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authValue,
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String endpoint) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken() ?? '';
    return http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final user = FirebaseAuth.instance.currentUser;
    final String? token = await user?.getIdToken();

    return http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }
}