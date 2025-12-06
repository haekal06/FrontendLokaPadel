import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:loka_padel/pages/profile/edit_profile.dart';
import 'package:loka_padel/pages/welcome/welcome_page.dart';
import 'package:loka_padel/services/auth_service.dart';
import 'package:loka_padel/services/api_client.dart';
import 'package:loka_padel/pages/profile/bantuan_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final auth = AuthService.instance;
  bool _uploadingPhoto = false;

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();

    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();

      setState(() => _uploadingPhoto = true);

      final resp = await ApiClient.uploadProfilePhoto(
        bytes as Uint8List,
        picked.name,
        token: auth.token,
      );

      debugPrint('UPLOAD FOTO PROFIL status: ${resp.statusCode}');
      debugPrint('UPLOAD FOTO PROFIL body  : ${resp.body}');

      if (resp.statusCode == 200) {
        final data = ApiClient.safeDecode(resp.body);
        final url = data['data']?['profile_photo_url']?.toString();

        debugPrint('PROFILE PHOTO URL dari server: $url');

        if (url != null && url.isNotEmpty) {
          auth.updateAvatar(url);
          debugPrint('AVATAR URL DISIMPAN di AuthService: ${auth.avatarUrl}');

          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengambil URL foto dari server'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload foto: ${resp.body}')),
        );
      }
    } catch (e) {
      debugPrint('ERROR upload foto profil: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
      }
    }
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadPhoto();
                },
              ),
              // Jika nanti ingin tambah kamera:
              // ListTile(
              //   leading: const Icon(Icons.camera_alt),
              //   title: const Text('Ambil dari Kamera'),
              //   onTap: () { ... },
              // ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = auth.userName.isNotEmpty ? auth.userName : 'Pengguna';
    final displayEmail =
        auth.email.isNotEmpty ? auth.email : 'email@domain.com';

    ImageProvider avatarImage;
    if (auth.avatarUrl.isNotEmpty) {
      debugPrint('AVATAR URL di build(): ${auth.avatarUrl}');
      avatarImage = NetworkImage(auth.avatarUrl);
    } else {
      avatarImage = const AssetImage('assets/images/profile.jpeg');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // =======================
          // 🔹 HEADER PROFIL
          // =======================
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF002D62),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // FOTO PROFIL + LOADER
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(radius: 45, backgroundImage: avatarImage),
                    if (_uploadingPhoto)
                      const CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.black38,
                        child: SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // TOMBOL EDIT FOTO PROFIL
                TextButton.icon(
                  onPressed: _uploadingPhoto ? null : _showPhotoSourceSheet,
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'Edit Foto Profil',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // NAMA
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // EMAIL
                Text(
                  displayEmail,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // =======================
          // 🔹 MENU LIST
          // =======================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                // Edit Profile
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.black54),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                    setState(() {});
                  },
                ),
                const Divider(),

                // Bantuan
                ListTile(
                  leading: const Icon(
                    Icons.help_outline,
                    color: Colors.black54,
                  ),
                  title: const Text('Bantuan'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BantuanPage()),
                    );
                  },
                ),
                const Divider(),

                // Logout
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.red,
                  ),
                  onTap: () {
                    auth.logout();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Logout berhasil!")),
                    );

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomePage(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
