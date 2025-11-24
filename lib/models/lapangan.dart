// lib/models/lapangan.dart

class Lapangan {
  final int id;
  final String nama;
  final int hargaPerJam;
  final String gambarUrl;

  Lapangan({
    required this.id,
    required this.nama,
    required this.hargaPerJam,
    required this.gambarUrl,
  });

  factory Lapangan.fromJson(Map<String, dynamic> json) {
    // harga_per_jam kadang bisa numeric, kadang string "450000.00"
    final rawHarga = json['harga_per_jam'];

    int parsedHarga = 0;
    if (rawHarga is num) {
      parsedHarga = rawHarga.toInt();
    } else if (rawHarga is String) {
      // buang .00 kalau ada
      final cleaned = rawHarga.split('.').first;
      parsedHarga = int.tryParse(cleaned) ?? 0;
    }

    return Lapangan(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      hargaPerJam: parsedHarga,
      gambarUrl: json['gambar_url']?.toString() ?? '',
    );
  }
}
