// lib/pages/beranda/beranda.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:loka_padel/models/lapangan.dart';
import 'package:loka_padel/services/lapangan_service.dart';
import 'package:loka_padel/pages/beranda/teknis.dart';
import 'package:loka_padel/pages/beranda/tips.dart';

class BerandaPage extends StatefulWidget {
  final String userName;

  const BerandaPage({super.key, required this.userName});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final LapanganService _lapanganService = LapanganService();

  final PageController _pageController = PageController(viewportFraction: 0.93);

  List<Lapangan> _lapangans = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchLapangans();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _fetchLapangans() async {
    try {
      final result = await _lapanganService.fetchLapangan();
      if (!mounted) return;
      setState(() {
        _lapangans = result;
        _isLoading = false;
      });

      if (_lapangans.length > 1) {
        _startAutoSlide();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat lapangan: $e';
        _isLoading = false;
      });
    }
  }

  void _startAutoSlide() {
    _timer?.cancel();
    if (_lapangans.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_pageController.hasClients) return;

      int nextPage = _currentPage + 1;
      if (nextPage >= _lapangans.length) {
        nextPage = 0;
      }

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage = nextPage;
      });
    });
  }

  String _formatHarga(int harga) {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return '${f.format(harga)} / Jam';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ================= HEADER =================
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF002B5B),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(15, 20, 20, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/img/logo_loka2.png',
                        height: 60,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Halo, ${widget.userName} 👋🏻",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "LokaPadel Jakarta",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= SLIDER LAPANGAN =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSlider(),
              ),

              const SizedBox(height: 20),

              // ================= ARTIKEL & TIPS =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Artikel & Tips",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Artikel 1
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TipsPage(),
                          ),
                        );
                      },
                      child: artikelCard(
                        "assets/img/semiioutdoor.jpg",
                        "Cara Memilih Lapangan",
                        "Tips cepat untuk memilih lapangan padel yang pas buat kamu.",
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Artikel 2
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TeknisPage(),
                          ),
                        );
                      },
                      child: artikelCard(
                        "assets/img/artikel.jpg",
                        "Teknik Servis yang Baik",
                        "Panduan dasar untuk meningkatkan akurasi dan kekuatan servis padelmu.",
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SLIDER WIDGET =================
  Widget _buildSlider() {
    if (_isLoading) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 210,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 210,
          color: Colors.grey[200],
          child: Center(child: Text(_error!, textAlign: TextAlign.center)),
        ),
      );
    }

    if (_lapangans.isEmpty) {
      // fallback kalau belum ada data lapangan
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/img/VIP.jpg',
          height: 210,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _lapangans.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final lap = _lapangans[index];
              final hargaText = _formatHarga(lap.hargaPerJam);

              Widget image;
              if (lap.gambarUrl.isNotEmpty &&
                  lap.gambarUrl.toLowerCase().startsWith('http')) {
                image = Image.network(
                  lap.gambarUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              } else {
                image = Image.asset(
                  'assets/img/indoor.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      image,
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.05),
                              Colors.black.withOpacity(0.6),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 32,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lap.nama,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hargaText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _lapangans.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _currentPage == index
                        ? const Color(0xFF002B5B)
                        : Colors.grey[400],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= WIDGET ARTIKEL CARD =================
  Widget artikelCard(String image, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.asset(
              image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
