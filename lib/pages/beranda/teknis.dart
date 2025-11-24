import 'package:flutter/material.dart';

class TeknisPage extends StatelessWidget {
  const TeknisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(250), // Sesuaikan tinggi dengan gambar
        child: Stack(
          children: [
            Image.asset(
              'assets/img/artikel.jpg',
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

      // ======== ISI HALAMAN ========
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ===== Judul Halaman =====
            const Center(
              child: Text(
                "Teknis Servis yang Baik",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            // ===== Konten Artikel =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: const [
                  TipsCard(
                    title: "1. Posisikan Tubuh dengan Benar",
                    content:
                        "Berdiri dengan kaki selebar bahu, lutut sedikit tekuk, dan berat badan pada kaki belakang. Posisi yang stabil membantu menghasilkan servis yang kuat dan terarah.",
                  ),
                  SizedBox(height: 12),

                  TipsCard(
                    title: "2. Pegang Raket dengan Grip Tepat",
                    content:
                        "Gunakan posisi genggaman yang ergonomis agar pukulanmu terasa nyaman. Pastikan genggaman tidak terlalu kencang agar ayunan lebih alami.",
                  ),
                  SizedBox(height: 12),

                  TipsCard(
                    title: "3. Lempar Bola dengan Konsisten",
                    content:
                        "Lempar bola sedikit ke depan dan ke atas kepala. Konsistensi lemparan membantu bola mudah mengenai area target dengan stabil.",
                  ),
                  SizedBox(height: 12),

                  TipsCard(
                    title: "4. Ayunan dan Latihan Servis",
                    content:
                        "Gunakan otot bahu dan pinggul agar pukulan bertenaga dan akurat. Latih servis secara rutin dengan variasi arah dan kecepatan untuk menjaga konsistensi permainan.",
                  ),
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

// ==================== WIDGET KARTU TIPS ====================
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
