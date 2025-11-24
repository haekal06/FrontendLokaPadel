import 'package:flutter/material.dart';
import 'package:loka_padel/pages/booking/booking_page.dart';

class DetailLapanganPage extends StatelessWidget {
  final int lapanganId;
  final String nama;
  final String lokasi;
  final String harga;
  final int hargaPerJam;
  final String gambar;
  final List fasilitas;

  const DetailLapanganPage({
    super.key,
    required this.lapanganId,
    required this.nama,
    required this.lokasi,
    required this.harga,
    required this.hargaPerJam,
    required this.gambar,
    required this.fasilitas,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0A3A67),
      body: SafeArea(
        child: Column(
          children: [
            // ================== HEADER ==================
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.arrow_back,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Detail Lapangan',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // ================== GAMBAR ==================
            SizedBox(
              height: 220,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Biru di bagian atas
                  Container(
                    width: double.infinity,
                    height: 130,
                    color: const Color(0xff0A3A67),
                  ),

                  // Putih mulai dari tengah ke bawah gambar (background kartu)
                  Positioned(
                    top: 140,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 150,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                      ),
                    ),
                  ),

                  // Gambar di atas transisi biru -> putih, sudut atas & bawah melengkung
                  Positioned(
                    top: 20,
                    left: 16,
                    right: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child:
                          gambar.startsWith('http')
                              ? Image.network(
                                gambar,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              )
                              : Image.asset(
                                gambar,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                    ),
                  ),
                ],
              ),
            ),

            // ================== AREA PUTIH UTAMA ==================
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // ========= CARD INFO ==========
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nama,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      lokasi,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  harga,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  "LokaPadel adalah destinasi padel premium dengan lapangan berkarpet sintetis khusus padel berisi pasir silika di atas lantai beton yang rata, sehingga pijakan stabil dan pantulan bola konsisten. Dikelilingi dinding kaca tempered dan pagar khas padel, tempat ini menawarkan suasana modern dengan area tunggu nyaman, ruang ganti, dan spot santai, ideal untuk latihan, sparring, maupun quality time bersama teman dan keluarga.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ========= CARD FASILITAS ==========
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fasilitas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Column(
                                  children: List.generate(
                                    fasilitas.length,
                                    (i) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_box_outlined,
                                            color: Color(0xff0A3A67),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              fasilitas[i]['text'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ========= BUTTON "PESAN SEKARANG" ==========
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff0A3A67),
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              // Navigasi ke halaman pemesanan (BookingPage)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => BookingPage(
                                        lapanganId: lapanganId,
                                        lapangan: nama,
                                        hargaPerJam: hargaPerJam,
                                      ),
                                ),
                              );
                            },
                            child: const Text(
                              'Pesan Sekarang',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
