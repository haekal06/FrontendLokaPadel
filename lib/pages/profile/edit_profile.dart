import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loka_padel/services/auth_service.dart';
import 'package:loka_padel/services/api_client.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;

  // Controller untuk password
  late TextEditingController _currentPassCtrl;
  late TextEditingController _newPassCtrl;
  late TextEditingController _confirmPassCtrl;

  final auth = AuthService.instance;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: auth.userName);
    _emailCtrl = TextEditingController(text: auth.email);

    _currentPassCtrl = TextEditingController();
    _newPassCtrl = TextEditingController();
    _confirmPassCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  bool get _isPasswordSectionFilled =>
      _currentPassCtrl.text.isNotEmpty ||
      _newPassCtrl.text.isNotEmpty ||
      _confirmPassCtrl.text.isNotEmpty;

  Future<bool> _updateProfile() async {
    final newName = _nameCtrl.text.trim();
    final newEmail = _emailCtrl.text.trim();

    if (auth.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sesi login berakhir, silakan login ulang."),
        ),
      );
      return false;
    }

    final response = await ApiClient.postJson('profile/update', {
      'name': newName,
      'email': newEmail,
    }, token: auth.token);

    debugPrint('UPDATE PROFILE status: ${response.statusCode}');
    debugPrint('UPDATE PROFILE body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (decoded['success'] == true) {
        final data = decoded['data'] as Map<String, dynamic>;
        auth.updateProfile(
          name: data['name']?.toString() ?? newName,
          email: data['email']?.toString() ?? newEmail,
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              decoded['message']?.toString() ?? "Gagal memperbarui profil.",
            ),
          ),
        );
        return false;
      }
    } else {
      String msg = "Gagal memperbarui profil.";
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          msg = decoded['message'].toString();
        }
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return false;
    }
  }

  Future<bool> _changePasswordIfNeeded() async {
    // Kalau semua field password kosong → tidak perlu ganti password
    if (!_isPasswordSectionFilled) return true;

    // Validasi basic di sisi Flutter
    if (_currentPassCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password lama tidak boleh kosong.")),
      );
      return false;
    }
    if (_newPassCtrl.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password baru minimal 8 karakter.")),
      );
      return false;
    }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi password baru tidak cocok.")),
      );
      return false;
    }

    if (auth.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sesi login berakhir, silakan login ulang."),
        ),
      );
      return false;
    }

    final response = await ApiClient.postJson('change-password', {
      'current_password': _currentPassCtrl.text,
      'new_password': _newPassCtrl.text,
      'new_password_confirmation': _confirmPassCtrl.text,
    }, token: auth.token);

    debugPrint('CHANGE PASSWORD status: ${response.statusCode}');
    debugPrint('CHANGE PASSWORD body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (decoded['success'] == true) {
        // kosongkan field password setelah sukses
        _currentPassCtrl.clear();
        _newPassCtrl.clear();
        _confirmPassCtrl.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              decoded['message']?.toString() ?? "Password berhasil diubah.",
            ),
          ),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              decoded['message']?.toString() ?? "Gagal mengubah password.",
            ),
          ),
        );
        return false;
      }
    } else if (response.statusCode == 422) {
      // kemungkinan password lama salah / validasi gagal
      String msg = "Gagal mengubah password.";
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          msg = decoded['message'].toString();
        }
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return false;
    } else {
      String msg = "Gagal mengubah password.";
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          msg = decoded['message'].toString();
        }
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return false;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // 1. Update nama & email dulu
      final okProfile = await _updateProfile();
      if (!okProfile) {
        // kalau profile gagal, jangan lanjut ubah password
        return;
      }

      // 2. Kalau user isi bagian password → kirim ke backend
      final okPassword = await _changePasswordIfNeeded();
      if (!okPassword) {
        // kalau password gagal, tetap stay di halaman, tapi profile sudah terupdate
        return;
      }

      // 3. Kalau semua berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui!")),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error di _saveProfile: $e');
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF002D62),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ====== NAMA ======
                const Text(
                  "Nama",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    hintText: "Masukkan nama baru",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ====== EMAIL ======
                const Text(
                  "Email",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    hintText: "Masukkan email baru",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@')) {
                      return 'Email harus mengandung @';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // ====== SECTION UBAH PASSWORD ======
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  "Ubah Password (opsional)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),

                const Text(
                  "Password Lama",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _currentPassCtrl,
                  decoration: const InputDecoration(
                    hintText: "Masukkan password lama",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                const Text(
                  "Password Baru",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _newPassCtrl,
                  decoration: const InputDecoration(
                    hintText: "Masukkan password baru (min. 8 karakter)",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                const Text(
                  "Konfirmasi Password Baru",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmPassCtrl,
                  decoration: const InputDecoration(
                    hintText: "Ulangi password baru",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),

                const SizedBox(height: 30),

                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002D62),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSaving ? null : _saveProfile,
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
                              "Simpan",
                              style: TextStyle(color: Colors.white),
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
}
