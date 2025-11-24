import 'package:flutter/material.dart';
import 'package:loka_padel/pages/daftar/daftar_page.dart';

class TombolDaftar extends StatelessWidget {
  const TombolDaftar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: () {
          // 🔹 Arahkan ke halaman pendaftaran
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DaftarPage()),
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          'Daftar',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
