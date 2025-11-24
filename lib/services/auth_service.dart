// lib/services/auth_service.dart
import 'dart:convert';

import 'package:loka_padel/services/api_client.dart';

class AuthService {
  // ===== Singleton =====
  AuthService._();
  static final AuthService instance = AuthService._();

  // ===== Data user yang sedang login =====
  int? _userId;
  String? _userName;
  String? _email;
  String? _role;
  String? _token;

  int? get userId => _userId;
  String get userName => _userName ?? '';
  String get email => _email ?? '';
  String? get role => _role;
  String? get token => _token;

  /// Login ke backend Laravel
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiClient.post("login", {
      "email": email,
      "password": password,
    });

    print("LOGIN STATUS: ${response.statusCode}");
    print("LOGIN RAW: ${response.body}");

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = {};
    }

    // Kalau sukses, simpan data user & token di memori
    if (response.statusCode == 200) {
      final user = body["user"] as Map<String, dynamic>? ?? {};
      _userId = user["id"] as int?;
      _userName = user["name"]?.toString();
      _email = user["email"]?.toString();
      _role = user["role"]?.toString();
      _token = body["token"]?.toString();
    }

    return {"status": response.statusCode, "data": body};
  }

  /// Update nama / email setelah edit profile
  void updateProfile({String? name, String? email}) {
    if (name != null) _userName = name;
    if (email != null) _email = email;
  }

  /// Bersihkan data saat logout
  void logout() {
    _userId = null;
    _userName = null;
    _email = null;
    _role = null;
    _token = null;
  }
}
