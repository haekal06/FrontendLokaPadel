import 'package:flutter/material.dart';
import 'package:loka_padel/pages/profile/edit_profile.dart';
import 'package:loka_padel/pages/welcome/welcome_page.dart';
import 'package:loka_padel/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final auth = AuthService.instance;

  @override
  Widget build(BuildContext context) {
    final displayName = auth.userName.isNotEmpty ? auth.userName : 'Pengguna';
    final displayEmail =
        auth.email.isNotEmpty ? auth.email : 'email@domain.com';

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
                const CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage('assets/images/profile.jpeg'),
                ),
                const SizedBox(height: 10),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                    // Setelah kembali dari edit, rebuild supaya nama/email terbaru tampil
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Menu Bantuan belum tersedia"),
                      ),
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
                    // bersihkan data user di AuthService
                    auth.logout();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Logout berhasil!")),
                    );

                    // Arahkan balik ke WelcomePage, hapus semua route sebelumnya
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
