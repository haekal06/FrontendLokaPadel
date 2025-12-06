// bantuan_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loka_padel/services/api_client.dart';
import 'package:loka_padel/services/auth_service.dart';

class BantuanService {
  Future<List<Map<String, dynamic>>> fetchRiwayat() async {
    final token = AuthService.instance.token;
    final resp = await ApiClient.get('bantuan', token: token);

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Gagal memuat riwayat bantuan');
    }
  }
}
