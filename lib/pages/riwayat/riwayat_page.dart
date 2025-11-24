import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loka_padel/services/auth_service.dart';
import '/pages/riwayat/detail_riwayat_page.dart';
import '/services/api_client.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _riwayatList = [];

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = AuthService.instance.userId;
      final token = AuthService.instance.token;

      if (userId == null || token == null) {
        setState(() {
          _error = 'Sesi login berakhir, silakan login ulang.';
          _isLoading = false;
        });
        return;
      }

      final res = await ApiClient.get('pemesanan/user/$userId', token: token);

      debugPrint('RIWAYAT status: ${res.statusCode}');
      debugPrint('RIWAYAT body: ${res.body}');

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        if (decoded['success'] == true) {
          final List<dynamic> items = decoded['data'] ?? [];

          setState(() {
            _riwayatList =
                items.map((e) => Map<String, dynamic>.from(e)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = decoded['message']?.toString() ?? 'Gagal memuat riwayat';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Error ${res.statusCode}: ${res.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error load riwayat: $e');
      setState(() {
        _error = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  String _formatTanggal(String raw) {
    try {
      final dt = DateTime.parse(raw); // format yyyy-MM-dd
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _formatWaktu(Map<String, dynamic> data) {
    final start = data['waktu']?.toString() ?? '';
    final end = data['waktu_selesai']?.toString();
    if (end != null && end.isNotEmpty) {
      return '$start - $end WIB';
    }
    return '$start WIB';
  }

  String _formatHarga(num value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  // Menentukan status berdasarkan waktu sekarang
  String _getStatus(Map<String, dynamic> data) {
    final now = DateTime.now();
    final startTime = DateFormat(
      "yyyy-MM-dd HH:mm:ss",
    ).parse("${data['tanggal']} ${data['waktu']}");
    final endTime = startTime.add(Duration(hours: data['durasi']));

    if (now.isBefore(startTime)) {
      return 'Mendatang';
    } else if (now.isAfter(endTime)) {
      return 'Selesai';
    } else {
      return 'Berlangsung';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002B5B),
        title: const Text("Riwayat", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadRiwayat,
        child: Padding(padding: const EdgeInsets.all(16), child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_riwayatList.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat pemesanan.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _riwayatList.length,
      itemBuilder: (context, index) {
        final data = _riwayatList[index];

        final nama = data['lapangan_nama']?.toString() ?? 'Lapangan';
        final tanggal = _formatTanggal(data['tanggal']?.toString() ?? '');
        final waktu = _formatWaktu(data);

        final totalHargaRaw = data['total_harga'] ?? 0;
        final totalHarga =
            totalHargaRaw is num
                ? totalHargaRaw
                : num.tryParse(totalHargaRaw.toString()) ?? 0;

        final harga = _formatHarga(totalHarga);
        String status = _getStatus(data); // Menggunakan fungsi _getStatus

        // Gambar dari backend
        final gambarUrl = data['lapangan_gambar']?.toString();
        Widget gambarWidget;
        if (gambarUrl != null && gambarUrl.startsWith('http')) {
          gambarWidget = Image.network(
            gambarUrl,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        } else {
          // fallback kalau backend tidak kirim gambar
          gambarWidget = Image.asset(
            'assets/img/indoor.jpg',
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        }

        Color badgeBg;
        Color badgeText;
        switch (status) {
          case 'Selesai':
            badgeBg = Colors.green[100]!;
            badgeText = Colors.green[800]!;
            break;
          case 'Berlangsung':
            badgeBg = Colors.orange[100]!;
            badgeText = Colors.orange[800]!;
            break;
          default:
            badgeBg = Colors.blue[100]!;
            badgeText = Colors.blue[800]!;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: gambarWidget,
                ),
                const SizedBox(height: 8),
                Text(
                  nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$tanggal\nWaktu: $waktu',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  harga,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge status main
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: badgeText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF002B5B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailRiwayatPage(data: data),
                          ),
                        );
                      },
                      child: const Text(
                        "Lihat Detail",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
