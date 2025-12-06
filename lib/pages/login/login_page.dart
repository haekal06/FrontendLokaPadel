import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loka_padel/main.dart';
import 'package:loka_padel/services/auth_service.dart';
import '../daftar/daftar_page.dart';
import '../welcome/welcome_page.dart'; // WelcomePage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    print('[_login] dipanggil');
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.instance.login(
        _emailCtrl.text.trim().toLowerCase(), // paksa lowercase ke backend
        _passCtrl.text,
      );

      final status = result['status'] as int;
      final data = result['data'] as Map<String, dynamic>;
      print('[_login] statusCode: $status');
      print('[_login] body: ${jsonEncode(data)}');

      if (!mounted) return;

      if (status == 200) {
        final user = data['user'] as Map<String, dynamic>? ?? {};
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login berhasil sebagai ${user['name'] ?? 'Pengguna'}',
            ),
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        });
      } else if (status == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message']?.toString() ?? 'Email atau password salah!',
            ),
          ),
        );
      } else if (status == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message']?.toString() ?? 'Akses hanya untuk pelanggan!',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan ($status), coba lagi.')),
        );
      }
    } catch (e) {
      print('[_login] exception: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal terhubung ke server: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2D5B),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 100),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Image.asset('assets/img/logo_loka2.png', width: 250),
                  const SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _emailCtrl,
                          hint: "Email",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _passCtrl,
                          hint: "Password",
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 35),
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
                            onPressed: _isLoading ? null : _login,
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
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Belum punya akun? ",
                              style: TextStyle(color: Colors.white70),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DaftarPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Daftar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: const [
                            Expanded(
                              child: Divider(
                                color: Colors.white24,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "Login dengan",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white24,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialIcon('assets/icons/facebook.png', () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WelcomePage(),
                                ),
                              );
                            }),
                            const SizedBox(width: 25),
                            _buildSocialIcon('assets/icons/google.png', () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WelcomePage(),
                                ),
                              );
                            }),
                            const SizedBox(width: 25),
                            _buildSocialIcon('assets/icons/instagram.png', () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WelcomePage(),
                                ),
                              );
                            }),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    final bool isEmailField = hint == "Email";

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      // Tidak ada inputFormatter: biarkan user mengetik apa saja,
      // tapi kita paksa jadi lowercase di onChanged.
      onChanged:
          isEmailField
              ? (value) {
                final lower = value.toLowerCase();
                if (lower != value) {
                  controller.value = controller.value.copyWith(
                    text: lower,
                    selection: TextSelection.collapsed(offset: lower.length),
                  );
                }
              }
              : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$hint tidak boleh kosong';
        }
        if (isEmailField && !value.contains('@')) {
          return 'Email harus mengandung @';
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

  Widget _buildSocialIcon(String path, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Image.asset(path, width: 40, height: 40),
    );
  }
}
