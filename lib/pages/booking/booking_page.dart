import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loka_padel/services/auth_service.dart';
import '../pembayaran/pembayaran_page.dart';
import '../../services/api_client.dart';

class BookingPage extends StatefulWidget {
  final int lapanganId;
  final String lapangan;
  final int hargaPerJam;

  const BookingPage({
    super.key,
    required this.lapanganId,
    required this.lapangan,
    required this.hargaPerJam,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime selectedDate = DateTime.now();
  DateTime focusedMonth = DateTime.now();

  String? _selectedJamMulai;
  int _durasi = 1;
  String? _waktuSelesaiText;
  int _totalHarga = 0;
  bool _isSaving = false;

  String? _lastOrderId;

  /// Semua pilihan jam (master)
  final List<String> jamMulaiOptions = [
    '06:00',
    '07:00',
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
  ];

  /// Jam yang benar-benar tersedia (setelah difilter backend)
  List<String> _availableJam = [];

  /// Status loading saat fetch jam dari backend
  bool _isLoadingJam = false;

  @override
  void initState() {
    super.initState();
    // default: sebelum API, tampilkan semua
    _availableJam = List.from(jamMulaiOptions);
    // load jam tersedia untuk tanggal hari ini
    _loadAvailableJam();
  }

  /// Hitung total & jam selesai
  void _recalculate() {
    if (_selectedJamMulai == null) {
      setState(() {
        _waktuSelesaiText = null;
        _totalHarga = 0;
      });
      return;
    }

    final parts = _selectedJamMulai!.split(':');
    final startHour = int.tryParse(parts[0]) ?? 0;
    final startMinute = int.tryParse(parts[1]) ?? 0;

    final dtStart = DateTime(2024, 1, 1, startHour, startMinute);
    final dtEnd = dtStart.add(Duration(hours: _durasi));
    final endStr = DateFormat('HH:mm').format(dtEnd);

    setState(() {
      _waktuSelesaiText = endStr;
      _totalHarga = widget.hargaPerJam * _durasi;
    });
  }

  /// Ambil jam yang masih tersedia dari backend
  Future<void> _loadAvailableJam() async {
    setState(() {
      _isLoadingJam = true;
    });

    try {
      final tanggalIso = DateFormat('yyyy-MM-dd').format(selectedDate);

      final response = await ApiClient.get(
        'pemesanan/jam-tersedia?lapangan_id=${widget.lapanganId}&tanggal=$tanggalIso',
        token: AuthService.instance.token,
      );

      debugPrint('LOAD JAM status: ${response.statusCode}');
      debugPrint('LOAD JAM body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true) {
          final List<dynamic> data = decoded['available'] ?? [];

          final List<String> newAvailable =
              data.map((e) => e.toString()).toList()..sort();

          setState(() {
            _availableJam = newAvailable;

            // Jika jam yang sebelumnya dipilih sudah tidak available, reset
            if (!_availableJam.contains(_selectedJamMulai)) {
              _selectedJamMulai = null;
              _durasi = 1;
              _waktuSelesaiText = null;
              _totalHarga = 0;
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error load jam: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingJam = false;
        });
      }
    }
  }

  /// Submit booking + SnapToken
  Future<void> _submitBooking() async {
    if (_selectedJamMulai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan pilih jam mulai terlebih dahulu!"),
        ),
      );
      return;
    }

    if (_totalHarga < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Total harga tidak boleh 0!")),
      );
      return;
    }

    final userId = AuthService.instance.userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sesi login berakhir, silakan login ulang."),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final tanggalIso = DateFormat('yyyy-MM-dd').format(selectedDate);

      final response = await ApiClient.postJson('pemesanan', {
        'lapangan_id': widget.lapanganId,
        'tanggal': tanggalIso,
        'waktu': _selectedJamMulai,
        'durasi': _durasi,
        'user_id': userId,
      }, token: AuthService.instance.token);

      debugPrint('BOOKING status: ${response.statusCode}');
      debugPrint('BOOKING body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;

        if (decoded['success'] != true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal booking: ${decoded['message']}")),
          );
          return;
        }

        final snapToken = decoded['snapToken'];
        final data = decoded['data'] as Map<String, dynamic>?;

        if (snapToken == null) {
          throw "snapToken null dari server";
        }

        if (data != null) {
          _lastOrderId = data['order_id']?.toString() ?? 'ORDER-${data['id']}';
          debugPrint('Order ID: $_lastOrderId');
        }

        final tanggalFormat = DateFormat(
          'EEEE, dd MMMM yyyy',
          'id_ID',
        ).format(selectedDate);

        final waktuDisplay =
            _waktuSelesaiText != null
                ? '$_selectedJamMulai - $_waktuSelesaiText'
                : _selectedJamMulai!;

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PembayaranPage(
                  snapToken:
                      snapToken, // Pastikan snapToken dipassing dengan benar
                  lapangan: widget.lapangan, // Nama lapangan
                  tanggal: tanggalFormat, // Tanggal yang sudah diformat
                  waktu: waktuDisplay, // Waktu yang sudah diformat
                  total: _totalHarga, // Total harga
                  orderId: _lastOrderId ?? '',
                ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal booking: ${response.body}")),
        );
      }
    } catch (e) {
      debugPrint("Error booking: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2D5B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B2D5B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Pemesanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pilih Tanggal",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildCalendar(),
                const SizedBox(height: 30),

                const Text(
                  "Jam Mulai",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedJamMulai,
                    underline: Container(),
                    hint:
                        _isLoadingJam
                            ? const Text("Memuat jam tersedia...")
                            : const Text("Pilih jam mulai"),
                    items:
                        _availableJam
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged:
                        _isLoadingJam
                            ? null
                            : (value) {
                              setState(() => _selectedJamMulai = value);
                              _recalculate();
                            },
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Durasi (Jam)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // ====== DURASI DALAM CONTAINER DENGAN TOMBOL - / + ======
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_durasi > 1) {
                            setState(() {
                              _durasi--;
                              _recalculate();
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$_durasi Jam',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // batas maksimal 5 jam (bisa diubah)
                          if (_durasi < 5) {
                            setState(() {
                              _durasi++;
                              _recalculate();
                            });
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),

                if (_waktuSelesaiText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Selesai: $_waktuSelesaiText",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
                Text(
                  "Total Harga: Rp $_totalHarga",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002855),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _isSaving
                            ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              "Lanjutkan Pembayaran",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk mengatur kalender
  Widget _buildCalendar() {
    final currentMonth = DateFormat('MMMM yyyy', 'id_ID').format(focusedMonth);
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;

    // Monday = 1 -> 0, Sunday = 7 -> 6
    final startWeekday = firstDayOfMonth.weekday - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _previousMonth,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              currentMonth,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              onPressed: _nextMonth,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 4),

        Row(
          children:
              ['M', 'S', 'S', 'R', 'K', 'J', 'S']
                  .map(
                    (e) => Expanded(
                      child: Center(
                        child: Text(
                          e,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 4),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            childAspectRatio: 2.0,
          ),
          itemCount: startWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < startWeekday) {
              return const SizedBox.shrink();
            }
            final day = index - startWeekday + 1;
            return _buildDayButton(day);
          },
        ),
      ],
    );
  }

  Widget _buildDayButton(int day) {
    final date = DateTime(focusedMonth.year, focusedMonth.month, day);
    final isSelected =
        selectedDate.day == day &&
        selectedDate.month == focusedMonth.month &&
        selectedDate.year == focusedMonth.year;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
          _selectedJamMulai = null;
          _durasi = 1;
          _waktuSelesaiText = null;
          _totalHarga = 0;
        });
        _loadAvailableJam(); // reload jam untuk tanggal baru
      },
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF002855) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "$day",
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _nextMonth() {
    setState(() {
      focusedMonth = DateTime(focusedMonth.year, focusedMonth.month + 1);
    });
  }

  void _previousMonth() {
    setState(() {
      focusedMonth = DateTime(focusedMonth.year, focusedMonth.month - 1);
    });
  }
}
