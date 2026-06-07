import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Bantuan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Pertanyaan Populer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  _buildFaqItem(
                    'Bagaimana cara menghitung BMI?',
                    'Sistem kami secara otomatis menghitung BMI Anda berdasarkan input Tinggi dan Berat Badan pada menu Edit Profil.',
                  ),
                  const Divider(height: 1),
                  _buildFaqItem(
                    'Apakah program latihan ini gratis?',
                    'Ya, sebagian besar program dasar tersedia secara gratis. Anda dapat mengakses fitur premium dengan berlangganan.',
                  ),
                  const Divider(height: 1),
                  _buildFaqItem(
                    'Bagaimana cara mengubah profil?',
                    'Masuk ke menu Profil, lalu ketuk opsi "Edit Profil" yang berada di baris pertama pada menu pengaturan.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Masih butuh bantuan?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membuka aplikasi Email...')),
              );
            },
            icon: const Icon(Icons.email_outlined),
            label: const Text('Hubungi Dukungan (Email)'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      collapsedIconColor: Colors.grey,
      iconColor: Colors.blue,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: const TextStyle(color: Colors.black54, height: 1.5),
          ),
        ),
      ],
    );
  }
}
