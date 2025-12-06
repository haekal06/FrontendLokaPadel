import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loka_padel/services/api_client.dart';
import 'package:loka_padel/services/auth_service.dart';

import 'package:loka_padel/pages/profile/riwayat_bantuan_page.dart';

class BantuanPage extends StatefulWidget {
  const BantuanPage({super.key});

  @override
  State<BantuanPage> createState() => _BantuanPageState();
}

class _BantuanPageState extends State<BantuanPage> {
  final _formKey = GlobalKey<FormState>();
  final _keluhanCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _keluhanCtrl.dispose();
    super.dispose();
  }

  Future<void> _kirimKeluhan() async {
    if (!_formKey.currentState!.validate()) return;

    final String? token = AuthService.instance.token;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi login berakhir, silakan login ulang.'),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final resp = await ApiClient.postJson('bantuan', {
        'deskripsi': _keluhanCtrl.text.trim(),
      }, token: token);

      debugPrint('KIRIM BANTUAN status: ${resp.statusCode}');
      debugPrint('KIRIM BANTUAN body  : ${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keluhan berhasil dikirim.')),
        );
        Navigator.pop(context);
      } else {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final msg =
            data['message']?.toString() ??
            'Gagal mengirim keluhan. Coba lagi nanti.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      debugPrint('ERROR KIRIM BANTUAN: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF002D62),
        title: const Text('Bantuan', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Bantuan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RiwayatBantuanPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deskripsi Bantuan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _keluhanCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Tuliskan keluhan atau pertanyaan Anda di sini...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Keluhan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002D62),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSending ? null : _kirimKeluhan,
                  child:
                      _isSending
                          ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            'Kirim',
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
