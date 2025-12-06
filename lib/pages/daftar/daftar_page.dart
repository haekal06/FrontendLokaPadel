import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../login/login_page.dart';

class DaftarPage extends StatefulWidget {
  const DaftarPage({super.key});

  @override
  State<DaftarPage> createState() => _DaftarPageState();
}

class _DaftarPageState extends State<DaftarPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // Sesuaikan dengan environment-mu:
  // - Flutter Web / browser: http://127.0.0.1:8000
  // - Android Emulator:     http://10.0.2.2:8000
  // - HP fisik:             http://IP_LAPTOP:8000  (dengan php artisan serve --host=0.0.0.0)
  final String _baseUrl = 'http://127.0.0.1:8000';

  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passCtrl.text.trim() != _confirmCtrl.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak cocok!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$_baseUrl/api/register-pelanggan');

      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          'name': _nameCtrl.text.trim(),
          // 👉 kirim email selalu dalam huruf kecil
          'email': _emailCtrl.text.trim().toLowerCase(),
          'password': _passCtrl.text,
        },
      );

      debugPrint('STATUS REGISTER: ${response.statusCode}');
      debugPrint('BODY REGISTER: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran berhasil! Silakan login.')),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        });
      } else {
        final data = _safeDecode(response.body);
        final message =
            data['message'] ?? 'Pendaftaran gagal. Periksa kembali data Anda.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      debugPrint('REGISTER ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal terhubung ke server. Periksa URL backend dan koneksi jaringan.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<String, dynamic> _safeDecode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2D5B), // warna biru navy
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  // Logo LokaPadel
                  Image.asset('assets/img/logo_loka.png', width: 480),
                  const SizedBox(height: 40),

                  const Text(
                    'Mulai Daftar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Form input
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameCtrl,
                          hint: 'Nama Lengkap',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _emailCtrl,
                          hint: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          isEmail: true, // 👉 penting: aktifkan mode email
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _passCtrl,
                          hint: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _confirmCtrl,
                          hint: 'Confirm Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 35),

                        // Tombol Daftar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 6,
                            ),
                            onPressed: _isLoading ? null : _register,
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                    : const Text(
                                      'Daftar Sekarang',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Link ke login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sudah punya akun? ',
                              style: TextStyle(color: Colors.white70),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi field input
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    bool isEmail = false, // 👉 tambahan flag untuk field email
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      onChanged:
          isEmail
              ? (value) {
                // paksa semua jadi huruf kecil
                final lower = value.toLowerCase();
                if (value != lower) {
                  final cursorPos = lower.length;
                  controller.value = TextEditingValue(
                    text: lower,
                    selection: TextSelection.collapsed(offset: cursorPos),
                  );
                }
              }
              : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$hint tidak boleh kosong';
        }
        if (isEmail) {
          if (!value.contains('@')) {
            return 'Format email tidak valid';
          }
          // kalau mau ekstra strict: pastikan tidak ada huruf besar
          if (value != value.toLowerCase()) {
            return 'Email harus menggunakan huruf kecil semua';
          }
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: const Color.fromRGBO(255, 255, 255, 0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
