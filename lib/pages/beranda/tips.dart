import 'package:flutter/material.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(250), // Sesuaikan tinggi dengan gambar
        child: Stack(
          children: [
            Image.asset(
              'assets/img/semiioutdoor.jpg',
              width: double.infinity,
              height: 250, // Sesuaikan tinggi gambar
              fit: BoxFit.cover,
            ),
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: 250, // Sesuaikan dengan tinggi gambar
              color: Colors.black.withOpacity(
                0.4,
              ), // Menambahkan transparansi untuk latar belakang gelap
              child: const Text(
                "Artikel & Tips",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24, // Sesuaikan ukuran font dengan gambar
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Cara Memilih Lapangan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: const [
                  TipsCard(
                    title: "Pilih Jenis Lapangan",
                    content:
                        "Setiap jenis lapangan memiliki keunggulan berbeda:\n\n"
                        "• Indoor → Bebas cuaca, pencahayaan stabil\n"
                        "• Semi Outdoor → Sirkulasi udara baik, tetap terlindungi\n"
                        "• Outdoor → Lebih luas dan segar, cocok untuk casual match\n\n"
                        "Pilih sesuai kenyamanan dan gaya bermain kamu.",
                  ),

                  SizedBox(height: 12),
                  TipsCard(
                    title: "Cek Kualitas Permukaan Lapangan ",
                    content:
                        "Permukaan yang baik akan membuat permainan lebih nyaman dan aman. Cari yang:\n\n"
                        "• Rumput sintetis premium\n"
                        "• Permukaan rata dan responsif\n"
                        "• Tidak licin\n\n"
                        "Ini mendukung kontrol bola dan mengurangi risiko cedera",
                  ),
                  SizedBox(height: 12),
                  TipsCard(
                    title: "Fasilitas yang Mendukung",
                    content:
                        "Pastikan tempat memiliki fasilitas yang memadai seperti:\n\n"
                        "• Ruang ganti\n"
                        "• Toilet & shower\n"
                        "• Area tunggu nyaman\n"
                        "• Parkir yang cukup\n\n"
                        "Semakin lengkap fasilitasnya, semakin nyaman pengalamanmu.",
                  ),
                  SizedBox(height: 12),
                  TipsCard(
                    title: "Sesuaikan dengan Budget",
                    content:
                        "Bandingkan harga setiap lapangan sesuai jam dan lokasi. Tidak selalu yang mahal paling cocok — pilih yang sesuai kebutuhan dan frekuensi bermainmu.",
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class TipsCard extends StatelessWidget {
  final String title;
  final String content;

  const TipsCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color.fromARGB(255, 8, 4, 92),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
