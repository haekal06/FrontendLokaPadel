import 'dart:async';
import 'dart:convert';
import 'dart:html' as html; // hanya untuk Flutter Web

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:loka_padel/services/api_client.dart';
import 'package:loka_padel/services/auth_service.dart';
// MainPage dari main.dart
import 'package:loka_padel/main.dart';

class PembayaranPage extends StatefulWidget {
  final String snapToken;
  final String lapangan;
  final String tanggal;
  final String waktu;
  final int total;

  // orderId untuk cek status pembayaran ke backend
  final String orderId;

  const PembayaranPage({
    super.key,
    required this.snapToken,
    required this.lapangan,
    required this.tanggal,
    required this.waktu,
    required this.total,
    required this.orderId,
  });

  @override
  _PembayaranPageState createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  bool isLoading = true;

  Timer? _statusTimer;
  bool _paymentSuccess = false;
  bool _checkingStatus = false;

  @override
  void initState() {
    super.initState();
    WebView.platform = SurfaceAndroidWebView();
    _startStatusPolling();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  // Mulai polling status
  void _startStatusPolling() {
    _checkPaymentStatus();
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkPaymentStatus();
    });
  }

  // Call backend: GET /api/pemesanan/status/{order_id}
  Future<void> _checkPaymentStatus() async {
    if (_paymentSuccess || _checkingStatus) return;

    final token = AuthService.instance.token;
    if (token == null) return;

    setState(() {
      _checkingStatus = true;
    });

    try {
      final response = await ApiClient.get(
        'pemesanan/status/${widget.orderId}',
        token: token,
      );

      debugPrint('CEK STATUS PEMBAYARAN: ${response.statusCode}');
      debugPrint('BODY STATUS: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final pemesanan = decoded['pemesanan'] as Map<String, dynamic>?;

        if (pemesanan != null) {
          final status = pemesanan['status']?.toString() ?? '';
          final statusPembayaran =
              pemesanan['status_pembayaran']?.toString() ?? '';

          // Sesuaikan dengan mapping di backend: 'paid' / 'Sukses'
          if (status == 'paid' || statusPembayaran == 'Sukses') {
            _onPaymentSuccess();
          }
        }
      }
    } catch (e) {
      debugPrint('ERROR CEK STATUS PEMBAYARAN: $e');
    } finally {
      if (mounted) {
        setState(() {
          _checkingStatus = false;
        });
      }
    }
  }

  void _onPaymentSuccess() {
    if (_paymentSuccess) return;

    _paymentSuccess = true;
    _statusTimer?.cancel();

    if (!mounted) return;

    _showSuccessPopup();
  }

  void _showSuccessPopup() {
    final userName = AuthService.instance.userName;

    // Tampilkan popup tengah
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 260,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  // Lingkaran + centang biru
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFE4ECF7), // biru muda
                    child: Icon(
                      Icons.check,
                      color: Color(0xFF002B5B), // biru tua
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Pesanan Berhasil!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF002B5B), // teks biru
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Setelah 3 detik: tutup popup dan pindah ke MainPage
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      // tutup dialog
      Navigator.of(context).pop();

      // arahkan ke MainPage (bottom nav lengkap: beranda, riwayat, dll)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => MainPage(userName: userName)),
        (route) => false,
      );
    });
  }

  // Masih bisa dipakai kalau Midtrans redirect ke URL tertentu
  void handlePaymentStatus(String url) {
    debugPrint("WebView URL: $url");

    if (url.contains("success")) {
      _onPaymentSuccess();
    } else if (url.contains("pending")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pembayaran sedang menunggu konfirmasi.")),
      );
    } else if (url.contains("failed") || url.contains("error")) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pembayaran gagal.")));
      Navigator.pop(context, "failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002B5B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002B5B),
        elevation: 0,
        title: const Text(
          'Pembayaran',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Detail Pembayaran',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailRow("Pemesanan", widget.lapangan),
                  _buildDetailRow("Tanggal", widget.tanggal),
                  _buildDetailRow("Waktu", widget.waktu),
                  _buildDetailRow("Total Pembayaran", "Rp ${widget.total}"),

                  const SizedBox(height: 24),

                  // Webview / tombol Midtrans
                  kIsWeb
                      ? ElevatedButton(
                        onPressed: () {
                          html.window.open(
                            "https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}",
                            "_blank",
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF2C3E50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Lanjutkan Pembayaran",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      )
                      : WebView(
                        initialUrl:
                            "https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}",
                        javascriptMode: JavascriptMode.unrestricted,
                        onPageStarted: (url) {
                          debugPrint("WebView URL Started: $url");
                          handlePaymentStatus(url);
                          setState(() {
                            isLoading = true;
                          });
                        },
                        onPageFinished: (url) {
                          debugPrint("WebView URL Finished: $url");
                          setState(() {
                            isLoading = false;
                          });
                        },
                      ),

                  const SizedBox(height: 16),

                  if (_checkingStatus)
                    const Center(
                      child: Text(
                        "Memeriksa status pembayaran...",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF0B2D5B),
            ),
          ),
        ],
      ),
    );
  }
}
