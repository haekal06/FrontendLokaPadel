// lib/services/lapangan_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/lapangan.dart';

class LapanganService {
  // KHUSUS WEB: Laravel & Flutter Web jalan di mesin yang sama
  final String _baseUrl = 'http://127.0.0.1:8000';

  Future<List<Lapangan>> fetchLapangan() async {
    final uri = Uri.parse('$_baseUrl/api/lapangan');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    // Debug log biar enak ngecek kalau ada masalah
    // ignore: avoid_print
    print('LAPANGAN status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);

      return decoded
          .map((item) => Lapangan.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Gagal memuat data lapangan (status: ${response.statusCode})',
      );
    }
  }
}
