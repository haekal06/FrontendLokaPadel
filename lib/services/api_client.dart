import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // Ganti ke URL backend Laravel Anda
  static const String baseUrl =
      "http://127.0.0.1:8000/api"; // Sesuaikan dengan URL backend Anda

  // POST normal (digunakan untuk login)
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data,
  ) {
    final url = Uri.parse("$baseUrl/$endpoint");

    return http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );
  }

  // POST JSON (untuk pemesanan Midtrans)
  static Future<http.Response> postJson(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) {
    final url = Uri.parse("$baseUrl/$endpoint");

    return http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );
  }

  // GET (opsional pakai token)
  static Future<http.Response> get(String endpoint, {String? token}) {
    final url = Uri.parse("$baseUrl/$endpoint");

    return http.get(
      url,
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );
  }
}
