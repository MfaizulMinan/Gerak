import 'package:flutter/material.dart';

class LaporanTab extends StatelessWidget {
  const LaporanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(backgroundImage: AssetImage('assets/images/fitness_avatar.png')), 
        ),
        title: const Text('Laporan Kebugaran', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kalori Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFE65C00), Color(0xFFF9D423)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.local_fire_department, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text('TOTAL KALORI TERBAKAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('12,500', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
                          SizedBox(width: 8),
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text('kkal', style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ],
                      )
                    ],
                  ),
                  Icon(Icons.local_fire_department, color: Colors.white.withValues(alpha: 0.3), size: 60),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Menit Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0052D4), Color(0xFF4364F7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.timer, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text('TOTAL MENIT LATIHAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('450', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
                          SizedBox(width: 8),
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text('menit', style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ],
                      )
                    ],
                  ),
                  Icon(Icons.timer, color: Colors.white.withValues(alpha: 0.3), size: 60),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Riwayat Latihan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {}, 
                  child: Row(
                    children: [
                      Text('Lihat Semua', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 16, color: Theme.of(context).primaryColor),
                    ],
                  )
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildHistoryCard(context, 'Lari Pagi', 'Hari ini, 06:30', '45 Menit', '420 kkal', Icons.directions_run),
            _buildHistoryCard(context, 'Latihan Beban', 'Kemarin, 17:00', '60 Menit', '380 kkal', Icons.fitness_center),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(child: Text('Indeks Massa Tubuh (BMI)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Atur Data'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('22.4', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                            SizedBox(width: 4),
                            Text('Normal', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Skor BMI Anda berada dalam batas sehat yang direkomendasikan.', style: TextStyle(color: Color(0xFF6C757D))),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(flex: 1, child: Container(height: 12, decoration: const BoxDecoration(color: Colors.cyanAccent, borderRadius: BorderRadius.horizontal(left: Radius.circular(6))))),
                      const SizedBox(width: 2),
                      Expanded(
                        flex: 2, 
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(height: 12, color: Colors.teal), // Active segment
                            Container(height: 20, width: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                            Container(height: 10, width: 10, decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle)),
                          ],
                        )
                      ),
                      const SizedBox(width: 2),
                      Expanded(flex: 2, child: Container(height: 12, color: Colors.orange.shade300)),
                      const SizedBox(width: 2),
                      Expanded(flex: 2, child: Container(height: 12, decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: const BorderRadius.horizontal(right: Radius.circular(6))))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kurus', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text('Normal', style: TextStyle(fontSize: 10, color: Colors.teal, fontWeight: FontWeight.bold)),
                      Text('Lebih', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text('Obese', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, String title, String time, String duration, String calories, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE5EDFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: Color(0xFF6C757D), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE5EDFF), borderRadius: BorderRadius.circular(8)),
                child: Text(duration, style: const TextStyle(color: Color(0xFF1A1D20), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 12),
                  const SizedBox(width: 2),
                  Text(calories, style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
