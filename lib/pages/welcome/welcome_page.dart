import 'package:flutter/material.dart';
import 'package:loka_padel/pages/welcome/tombol_login.dart';
import 'package:loka_padel/pages/welcome/tombol_daftar.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background Gambar
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/welcome.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔹 Overlay semi-transparan
          Container(color: Colors.black.withOpacity(0.4)),

          // 🔹 Konten
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔸 Logo besar di tengah layar
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/img/logo_loka.png',
                        width: screenWidth * 0.9,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 🔸 Deskripsi & tombol di bagian bawah
                  Column(
                    children: const [
                      Text(
                        'Menyiapkan lapangan terbaik untukmu',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      TombolLogin(),
                      SizedBox(height: 16),
                      TombolDaftar(),
                      SizedBox(height: 20),
                    ],
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
