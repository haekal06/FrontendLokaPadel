import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loka_padel/models/lapangan.dart';
import 'package:loka_padel/services/lapangan_service.dart';
import 'detail_lapangan_page.dart';

class LapanganPage extends StatefulWidget {
  const LapanganPage({super.key});

  @override
  State<LapanganPage> createState() => _LapanganPageState();
}

class _LapanganPageState extends State<LapanganPage> {
  final LapanganService _lapanganService = LapanganService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Lapangan> _lapanganList = [];

  @override
  void initState() {
    super.initState();
    _loadLapangan();
  }

  Future<void> _loadLapangan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _lapanganService.fetchLapangan();
      setState(() {
        _lapanganList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatRupiah(num value) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(value);
  }

  Widget _buildLapanganImage(String url) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Image.network(
        url,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0E0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.broken_image_outlined,
              color: Colors.orange,
              size: 40,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0A3A67),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
            color: const Color(0xff0A3A67),
            child: Row(
              children: [Image.asset("assets/img/logo_loka2.png", height: 44)],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pilih Lapangan",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Pilih jadwal dan lapangan sesuai kebutuhanmu!",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : (_errorMessage != null)
                            ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: _loadLapangan,
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            )
                            : GridView.builder(
                              itemCount: _lapanganList.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.78,
                                  ),
                              itemBuilder: (context, index) {
                                final lap = _lapanganList[index];
                                final hargaFormatted = _formatRupiah(
                                  lap.hargaPerJam,
                                );

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => DetailLapanganPage(
                                              lapanganId: lap.id,
                                              nama: lap.nama,
                                              lokasi: 'LokaPadel Jakarta',
                                              harga: '$hargaFormatted / Jam',
                                              hargaPerJam: lap.hargaPerJam,
                                              gambar: lap.gambarUrl,
                                              fasilitas: const [
                                                {
                                                  "icon": "wifi",
                                                  "text": "WiFi",
                                                },
                                                {
                                                  "icon": "shower",
                                                  "text": "Shower",
                                                },
                                                {
                                                  "icon": "local_parking",
                                                  "text": "Parkir",
                                                },
                                              ],
                                            ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLapanganImage(lap.gambarUrl),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                lap.nama,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                "LokaPadel Jakarta",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                '$hargaFormatted / Jam',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              _,
                                                            ) => DetailLapanganPage(
                                                              lapanganId:
                                                                  lap.id,
                                                              nama: lap.nama,
                                                              lokasi:
                                                                  'LokaPadel Jakarta',
                                                              harga:
                                                                  '$hargaFormatted / Jam',
                                                              hargaPerJam:
                                                                  lap.hargaPerJam,
                                                              gambar:
                                                                  lap.gambarUrl,
                                                              fasilitas: const [
                                                                {
                                                                  "icon":
                                                                      "wifi",
                                                                  "text":
                                                                      "WiFi",
                                                                },
                                                                {
                                                                  "icon":
                                                                      "shower",
                                                                  "text":
                                                                      "Shower",
                                                                },
                                                                {
                                                                  "icon":
                                                                      "local_parking",
                                                                  "text":
                                                                      "Parkir",
                                                                },
                                                              ],
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xff0A3A67),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "Detail Lapangan",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
