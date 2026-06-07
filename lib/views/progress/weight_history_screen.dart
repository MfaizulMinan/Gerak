import 'package:flutter/material.dart';

class WeightHistoryScreen extends StatelessWidget {
  const WeightHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Catatan: Ini adalah data dummy. Nantinya Anda bisa menggantinya
    // menggunakan StreamBuilder dari _firestoreService.getWeightHistory(_uid)
    final List<Map<String, dynamic>> dummyHistory = [
      {'date': '4 Jun 2026', 'weight': 68.5, 'diff': -0.5},
      {'date': '28 Mei 2026', 'weight': 69.0, 'diff': -1.2},
      {'date': '15 Mei 2026', 'weight': 70.2, 'diff': -0.8},
      {'date': '1 Mei 2026', 'weight': 71.0, 'diff': 0.0},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Riwayat Berat Badan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyHistory.length,
        itemBuilder: (context, index) {
          final item = dummyHistory[index];
          final isLoss = item['diff'] < 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.monitor_weight_rounded,
                  color: Colors.blue,
                ),
              ),
              title: Text(
                '${item['weight']} kg',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                item['date'],
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              trailing: item['diff'] == 0
                  ? const Text(
                      '-',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLoss ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isLoss ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item['diff'].abs()} kg',
                          style: TextStyle(
                            color: isLoss ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
