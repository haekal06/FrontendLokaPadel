import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:loka_padel/services/api_client.dart';
import 'package:loka_padel/services/auth_service.dart';

class RiwayatBantuanPage extends StatefulWidget {
  const RiwayatBantuanPage({super.key});

  @override
  State<RiwayatBantuanPage> createState() => _RiwayatBantuanPageState();
}

class _RiwayatBantuanPageState extends State<RiwayatBantuanPage> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    final String? token = AuthService.instance.token;

    if (token == null || token.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Sesi login berakhir, silakan login ulang.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resp = await ApiClient.get('bantuan', token: token);

      debugPrint('RIWAYAT BANTUAN status: ${resp.statusCode}');
      debugPrint('RIWAYAT BANTUAN body  : ${resp.body}');

      if (resp.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(resp.body) as Map<String, dynamic>;
        final List<dynamic> data = body['data'] as List<dynamic>;

        setState(() {
          _items = data.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Gagal memuat riwayat bantuan (status: ${resp.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('ERROR RIWAYAT BANTUAN: $e');
      setState(() {
        _error = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  String _formatTanggal(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final fmt = DateFormat('dd MMM yyyy HH:mm', 'id_ID');
      return fmt.format(dt);
    } catch (_) {
      return isoString;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'baru':
        return Colors.orange;
      case 'diproses':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'baru':
        return 'Baru';
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF002D62),
        title: const Text(
          'Riwayat Bantuan',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRiwayat,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadRiwayat,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                )
                : _items.isEmpty
                ? ListView(
                  padding: const EdgeInsets.all(20),
                  children: const [
                    Center(
                      child: Text(
                        'Belum ada riwayat keluhan.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final deskripsi = item['deskripsi']?.toString() ?? '-';
                    final status = item['status']?.toString() ?? 'baru';
                    final catatanAdmin =
                        item['catatan_admin']?.toString() ?? '';
                    final createdAt = item['created_at']?.toString();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(
                                      status,
                                    ).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    _statusLabel(status),
                                    style: TextStyle(
                                      color: _statusColor(status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatTanggal(createdAt),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Keluhan:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              deskripsi,
                              style: const TextStyle(fontSize: 13),
                            ),
                            if (catatanAdmin.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Balasan Admin:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                catatanAdmin,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
