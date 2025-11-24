import 'dart:html' as html; // Import hanya untuk Flutter Web
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import untuk kIsWeb
import 'package:webview_flutter/webview_flutter.dart';

class PembayaranPage extends StatefulWidget {
  final String snapToken;
  final String lapangan;
  final String tanggal;
  final String waktu;
  final int total;

  const PembayaranPage({
    super.key,
    required this.snapToken,
    required this.lapangan,
    required this.tanggal,
    required this.waktu,
    required this.total,
  });

  @override
  _PembayaranPageState createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WebView.platform = SurfaceAndroidWebView(); // Untuk platform Android
  }

  // Fungsi untuk menangani status pembayaran
  void handlePaymentStatus(String url) {
    print("WebView URL: $url");

    if (url.contains("success")) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pembayaran berhasil!")));
      Navigator.pop(context, "success");
    } else if (url.contains("pending")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pembayaran sedang menunggu konfirmasi.")),
      );
    } else if (url.contains("failed")) {
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
                  // Menampilkan Detail Pemesanan
                  _buildDetailRow("Pemesanan", widget.lapangan),
                  _buildDetailRow("Tanggal", widget.tanggal),
                  _buildDetailRow("Waktu", widget.waktu),
                  _buildDetailRow("Total Pembayaran", "Rp ${widget.total}"),
                  const SizedBox(height: 24),

                  // Webview untuk menampilkan halaman Midtrans
                  kIsWeb
                      ? ElevatedButton(
                        onPressed: () {
                          html.window.open(
                            "https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}",
                            "_blank", // Membuka di tab baru
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
                          print("WebView URL Started: $url");
                          handlePaymentStatus(url);
                          setState(() {
                            isLoading = true;
                          });
                        },
                        onPageFinished: (url) {
                          print("WebView URL Finished: $url");
                          setState(() {
                            isLoading = false;
                          });
                        },
                      ),

                  // Menampilkan progress jika sedang memuat halaman pembayaran
                  if (isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan informasi detail pembayaran
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
