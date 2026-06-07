import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../tracking/tracking_screen.dart';
import '../../models/workout_entry.dart';

class ProgramDetailScreen extends StatefulWidget {
  final Map<String, dynamic> program;

  const ProgramDetailScreen({super.key, required this.program});

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  int _selectedDay = 1;

  @override
  Widget build(BuildContext context) {
    final Color themeColor = widget.program['color'] as Color;
    final int totalDays = widget.program['totalDays'] as int;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.program['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Jadwal Latihan",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                    const Text(
                      "Nutrisi",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                const SizedBox(height: 16),

                SizedBox(
                  height: 75,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: totalDays,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final isSelected = _selectedDay == day;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 60,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? themeColor : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? themeColor
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Hari",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$day",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildLatihanTile(
                  "1",
                  "Target Otot Dada",
                  "4 Gerakan - 45 Menit",
                  themeColor,
                ),
                _buildLatihanTile(
                  "2",
                  "Target Otot Punggung",
                  "4 Gerakan - 45 Menit",
                  themeColor,
                ),
                _buildLatihanTile(
                  "3",
                  "Target Otot Kaki",
                  "4 Gerakan - 45 Menit",
                  themeColor,
                ),
                _buildLatihanTile(
                  "4",
                  "Target Otot Bahu",
                  "4 Gerakan - 45 Menit",
                  themeColor,
                ),
                _buildLatihanTile(
                  "5",
                  "Target Otot Rest",
                  "Jadwal Istirahat",
                  themeColor,
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () => _ambilProgram(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "AMBIL PROGRAM INI",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatihanTile(
    String nomor,
    String judul,
    String detail,
    Color themeColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: themeColor.withValues(alpha: 0.2),
            child: Text(
              nomor,
              style: TextStyle(
                color: themeColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hari $nomor: $judul",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Future<void> _ambilProgram(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final firestoreService = FirestoreService();

    // 1. Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Simpan program aktif
      await firestoreService.setActiveProgram(uid, {
        'programId': widget.program['id'],
        'title': widget.program['title'],
        'category': widget.program['category'],
        'totalDays': widget.program['totalDays'],
        'level': widget.program['level'],
      });

      // 3. MAGIC INJECTION SUPER (Looping 30 / 60 Hari)
      final today = DateTime.now();
      final totalDays = widget.program['totalDays'] as int;
      final programId = widget.program['id'];

      for (int i = 0; i < totalDays; i++) {
        final targetDate = today.add(Duration(days: i));

        if (programId == 'diet_60') {
          final dietEntry = WorkoutEntry(
            id: '',
            exerciseName: 'Jalan Santai / Kardio (Hari ${i + 1})',
            sets: 1,
            repsPerSet: 30,
            restSeconds: 0,
            isCompleted: false,
            lottieUrl:
                'https://assets4.lottiefiles.com/packages/lf20_1ynlqws2.json',
            targetMuscle: 'Seluruh Tubuh',
            caloriesPerSet: 150,
            createdAt: targetDate,
          );
          final makanEntry = WorkoutEntry(
            id: '',
            exerciseName: 'Cek Aturan Makan',
            sets: 1,
            repsPerSet: 1,
            restSeconds: 0,
            isCompleted: false,
            lottieUrl:
                'https://assets4.lottiefiles.com/packages/lf20_1ynlqws2.json',
            targetMuscle: 'Nutrisi',
            caloriesPerSet: 0,
            createdAt: targetDate,
          );

          await firestoreService.addWorkoutEntry(uid, targetDate, dietEntry);
          await firestoreService.addWorkoutEntry(uid, targetDate, makanEntry);
        } else {
          final latihan1 = WorkoutEntry(
            id: '',
            exerciseName: 'Push Up (Hari ${i + 1})',
            sets: 4,
            repsPerSet: 12,
            restSeconds: 60,
            isCompleted: false,
            lottieUrl:
                'https://assets2.lottiefiles.com/packages/lf20_msnmnh1b.json',
            targetMuscle: 'Dada & Lengan',
            caloriesPerSet: 15,
            createdAt: targetDate,
          );
          final latihan2 = WorkoutEntry(
            id: '',
            exerciseName: 'Plank (Hari ${i + 1})',
            sets: 3,
            repsPerSet: 1,
            restSeconds: 30,
            isCompleted: false,
            lottieUrl:
                'https://assets3.lottiefiles.com/packages/lf20_sz8jkxb9.json',
            targetMuscle: 'Perut (Core)',
            caloriesPerSet: 10,
            createdAt: targetDate,
          );

          await firestoreService.addWorkoutEntry(uid, targetDate, latihan1);
          await firestoreService.addWorkoutEntry(uid, targetDate, latihan2);
        }
      }

      if (context.mounted) {
        Navigator.pop(context); // Tutup loading
        Navigator.pop(context); // Tutup halaman detail kembali ke katalog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 Program "${widget.program['title']}" dimulai! Jadwal $totalDays hari disiapkan.',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // 4. Langsung Arahkan ke TrackingScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TrackingScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memulai program: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
