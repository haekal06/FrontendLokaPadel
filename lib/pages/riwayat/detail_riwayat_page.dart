import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// PDF & Printing
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DetailRiwayatPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailRiwayatPage({super.key, required this.data});

  String _formatTanggal(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return raw;
    }
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
    final nama = data['lapangan_nama']?.toString() ?? 'Lapangan';
    final tanggal = _formatTanggal(data['tanggal']?.toString() ?? '');
    final waktuMulai = data['waktu']?.toString() ?? '';
    final waktuSelesai = data['waktu_selesai']?.toString() ?? '';
    final durasi = data['durasi'] ?? 1;
    final statusMain = _getStatus(
      data,
    ); // Menggunakan fungsi _getStatus untuk mendapatkan status dinamis
    final statusPembayaran = data['status_pembayaran']?.toString() ?? 'Pending';
    final orderId = data['order_id']?.toString() ?? '–';
    final totalHarga =
        (data['total_harga'] ?? 0) is num
            ? data['total_harga'] as num
            : num.tryParse(data['total_harga'].toString()) ?? 0;

    final metodePembayaran =
        data['metode_pembayaran']?.toString() ?? 'Midtrans';

    // Gambar
    final gambarUrl = data['lapangan_gambar']?.toString();
    Widget gambarWidget;
    if (gambarUrl != null && gambarUrl.startsWith('http')) {
      gambarWidget = Image.network(
        gambarUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      gambarWidget = Image.asset(
        'assets/img/indoor.jpg',
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002B5B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Pemesanan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge Status
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      statusMain == 'Selesai'
                          ? Colors.green
                          : (statusMain == 'Berlangsung'
                              ? Colors.orange
                              : Colors.blue),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusMain,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Card Gambar Lapangan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: gambarWidget,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nama,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'LokaPadel Jakarta',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Status Pembayaran: $statusPembayaran',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  statusPembayaran == 'Sukses'
                                      ? Colors.green[800]
                                      : (statusPembayaran == 'Pending'
                                          ? Colors.orange[800]
                                          : Colors.red[800]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Rincian Waktu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rincian Waktu',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Tanggal: $tanggal', Colors.black87),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        'Waktu: $waktuMulai - $waktuSelesai ($durasi jam)',
                        Colors.black87,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Detail Transaksi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Transaksi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Nomor Pesanan: $orderId', Colors.black87),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        'Metode Bayar: $metodePembayaran',
                        Colors.black87,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Rincian Pembayaran
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rincian Pembayaran',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPriceRow(
                        'Sewa Lapangan ($durasi Jam)',
                        _formatHarga(totalHarga),
                        false,
                      ),
                      const SizedBox(height: 8),
                      _buildPriceRow('Biaya Admin', 'Rp 0', false),
                      const Divider(height: 24),
                      _buildPriceRow(
                        'TOTAL PEMBAYARAN',
                        _formatHarga(totalHarga),
                        true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // TOMBOL CETAK STRUK (PDF)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _generatePdfAndPrint(
                      namaLapangan: nama,
                      tanggal: tanggal,
                      waktuMulai: waktuMulai,
                      waktuSelesai: waktuSelesai,
                      durasi:
                          durasi is int
                              ? durasi
                              : int.tryParse(durasi.toString()) ?? 1,
                      orderId: orderId,
                      total: _formatHarga(totalHarga),
                      metodePembayaran: metodePembayaran,
                      statusPembayaran: statusPembayaran,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: const Text(
                    'Cetak Struk (PDF)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String text, Color color) {
    return Text(text, style: TextStyle(fontSize: 13, color: color));
  }

  Widget _buildPriceRow(String label, String price, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// =============== GENERATE PDF & PRINT ===============
  Future<void> _generatePdfAndPrint({
    required String namaLapangan,
    required String tanggal,
    required String waktuMulai,
    required String waktuSelesai,
    required int durasi,
    required String orderId,
    required String total,
    required String metodePembayaran,
    required String statusPembayaran,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'STRUK PEMESANAN',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'LokaPadel Jakarta',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),

              pw.SizedBox(height: 8),
              pw.Text('No. Pesanan  : $orderId'),
              pw.Text('Tanggal      : $tanggal'),
              pw.Text(
                'Waktu        : $waktuMulai - $waktuSelesai ($durasi jam)',
              ),
              pw.Text('Lapangan     : $namaLapangan'),
              pw.Text('Metode Bayar : $metodePembayaran'),
              pw.Text('Status Bayar : $statusPembayaran'),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 8),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL PEMBAYARAN',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    total,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),

              pw.SizedBox(height: 24),
              pw.Text(
                'Terima kasih telah bermain di LokaPadel.',
                style: pw.TextStyle(fontSize: 11),
              ),
              pw.Text(
                'Struk ini sah walaupun tanpa tanda tangan & stempel.',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          );
        },
      ),
    );

    // Buka dialog print / simpan PDF / share
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }
}
