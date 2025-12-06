import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiClient {
  // Ganti ke URL backend Laravel Anda
  // Catatan:
  // - Flutter Web / browser: http://127.0.0.1:8000/api
  // - Android Emulator:      http://10.0.2.2:8000/api
  // - HP fisik:              http://IP_LAPTOP:8000/api
  static const String baseUrl = "http://127.0.0.1:8000/api";

  /// Helper aman untuk decode JSON (kalau gagal, return {} saja)
  static Map<String, dynamic> safeDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  // ======================
  // POST normal (digunakan untuk login)
  // ======================
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data,
  ) {
    final url = Uri.parse("$baseUrl/$endpoint");

    return http.post(
      url,
      headers: const {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );
  }

  // ======================
  // POST JSON (umum, pakai optional Bearer token)
  // Contoh: pemesanan, update profile, bantuan, dll.
  // ======================
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

  // ======================
  // GET (opsional pakai token)
  // ======================
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

  // ======================
  // UPLOAD FOTO PROFIL (multipart)
  // dipakai di ProfilePage -> _pickAndUploadPhoto
  // Endpoint: POST /api/profile/photo (dengan Sanctum)
  // ======================
  static Future<http.Response> uploadProfilePhoto(
    Uint8List bytes,
    String filename, {
    String? token,
  }) async {
    final url = Uri.parse("$baseUrl/profile/photo");

    final request = http.MultipartRequest('POST', url)
      ..headers['Accept'] = 'application/json';

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Kalau mau lebih fleksibel, bisa deteksi tipe dari extension
    // Tapi untuk sekarang, pakai image/jpeg juga sudah aman
    request.files.add(
      http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: filename,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    // Debug optional
    // print('UPLOAD PROFILE PHOTO STATUS: ${response.statusCode}');
    // print('UPLOAD PROFILE PHOTO BODY  : ${response.body}');

    return response;
  }
}
