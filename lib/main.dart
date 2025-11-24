// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:loka_padel/pages/welcome/welcome_page.dart';
import 'package:loka_padel/pages/beranda/beranda.dart';
import 'package:loka_padel/pages/lapangan/lapangan_page.dart';
import 'package:loka_padel/pages/riwayat/riwayat_page.dart';
import 'package:loka_padel/pages/profile/profile.dart';
import 'package:loka_padel/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Loka Padel Club',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF002B5B),
      ),
      // pertama kali tetap ke WelcomePage
      home: const WelcomePage(),
    );
  }
}

// Halaman utama setelah login
class MainPage extends StatefulWidget {
  /// opsional: bisa dikirim dari LoginPage
  final String? userName;

  const MainPage({super.key, this.userName});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // ambil nama: dari parameter kalau ada, kalau tidak dari AuthService
    final String namaUser =
        widget.userName?.isNotEmpty == true
            ? widget.userName!
            : AuthService.instance.userName;

    final List<Widget> pages = [
      BerandaPage(userName: namaUser),
      LapanganPage(),
      const RiwayatPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF002B5B),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_tennis),
            label: 'Lapangan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
