import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import 'program_detail_screen.dart';
import '../tracking/tracking_screen.dart';
import '../../models/workout_entry.dart';

class ProgramCatalogScreen extends StatelessWidget {
  const ProgramCatalogScreen({super.key});

  static const List<Map<String, dynamic>> _programs = [
    {
      'id': 'bulking_30',
      'title': 'Bulking 30 Hari',
      'level': 'Menengah',
      'totalDays': 30,
      'icon': Icons.fitness_center,
      'color': Color(0xFF3B82F6),
      'desc':
          'Fokus hipertrofi untuk membangun massa otot secara efektif dengan nutrisi surplus kalori.',
      'category': 'Bulking',
    },
    {
      'id': 'cutting_30',
      'title': 'Cutting 30 Hari',
      'level': 'Lanjutan',
      'totalDays': 30,
      'icon': Icons.trending_down,
      'color': Color(0xFFEF4444),
      'desc':
          'Program pembakaran lemak intensif sambil mempertahankan massa otot tubuh.',
      'category': 'Cutting',
    },
    {
      'id': 'diet_60',
      'title': 'Diet Sehat 60 Hari',
      'level': 'Pemula',
      'totalDays': 60,
      'icon': Icons.restaurant_menu,
      'color': Color(0xFF10B981),
      'desc':
          'Pengaturan pola makan sehat yang berkelanjutan disertai olahraga ringan.',
      'category': 'Diet',
    },
    {
      'id': 'cardio_30',
      'title': 'Cardio Endurance 30 Hari',
      'level': 'Menengah',
      'totalDays': 30,
      'icon': Icons.directions_run,
      'color': Color(0xFFF59E0B),
      'desc':
          'Tingkatkan kapasitas kardiovaskular dan stamina dengan kardio harian yang terstruktur.',
      'category': 'Cardio Endurance',
    },
    {
      'id': 'flexibility_30',
      'title': 'Flexibility & Recovery',
      'level': 'Pemula',
      'totalDays': 30,
      'icon': Icons.self_improvement,
      'color': Color(0xFF8B5CF6),
      'desc':
          'Meningkatkan kelenturan tubuh dan mempercepat pemulihan otot pasca latihan.',
      'category': 'Flexibility & Recovery',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: uid == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<Map<String, dynamic>?>(
              stream: firestoreService.getActiveProgramStream(uid),
              builder: (ctx, snap) {
                final activeProgram = snap.data;
                final activeProgramId = activeProgram?['programId'];

                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 120,
                      pinned: true,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                12,
                                24,
                                16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [
                                  Text(
                                    'Program Fitness',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '5 program tersedia • Pilih sesuai tujuanmu',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (activeProgram != null)
                      SliverToBoxAdapter(
                        child: Builder(
                          builder: (context) {
                            final dayCompleted =
                                activeProgram['dayCompleted'] ?? 0;
                            final totalDays = activeProgram['totalDays'] ?? 30;
                            final progress = totalDays > 0
                                ? dayCompleted / totalDays
                                : 0.0;

                            return Container(
                              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(
                                    ctx,
                                  ).primaryColor.withValues(alpha: 0.3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(ctx).primaryColor
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'Program Aktif',
                                              style: TextStyle(
                                                color: Theme.of(
                                                  ctx,
                                                ).primaryColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            activeProgram['title'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            'Hari ke-$dayCompleted dari $totalDays hari',
                                            style: const TextStyle(
                                              color: Color(0xFF6C757D),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: ctx,
                                            builder: (c) => AlertDialog(
                                              title: const Text(
                                                'Batalkan Program?',
                                              ),
                                              content: const Text(
                                                'Progress kamu akan dihapus. Yakin ingin membatalkan?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(c, false),
                                                  child: const Text('Kembali'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(c, true),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                  child: const Text('Batalkan'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirmed == true) {
                                            await firestoreService
                                                .cancelActiveProgram(uid);
                                          }
                                        },
                                        child: const Text(
                                          'Batalkan',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey.shade100,
                                      valueColor: AlwaysStoppedAnimation(
                                        Theme.of(ctx).primaryColor,
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(progress * 100).toInt()}% selesai',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6C757D),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((ctx, i) {
                          final prog = _programs[i];
                          final color = prog['color'] as Color;
                          final isThisProgramActive =
                              prog['id'] == activeProgramId;

                          return _ProgramCard(
                            program: prog,
                            color: color,
                            isActive: isThisProgramActive,
                            onTap: () => Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProgramDetailScreen(program: prog),
                              ),
                            ),
                            onStart: isThisProgramActive
                                ? null
                                : () async {
                                    final confirmed = await showDialog<bool>(
                                      context: ctx,
                                      builder: (c) => AlertDialog(
                                        title: Text('Mulai ${prog['title']}?'),
                                        content: Text(
                                          'Program selama ${prog['totalDays']} hari akan dimulai.\nProgram aktif sebelumnya akan digantikan.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(c, false),
                                            child: const Text('Batal'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(c, true),
                                            child: const Text('Mulai Program'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed == true) {
                                      // 1. Tampilkan Loading
                                      showDialog(
                                        context: ctx,
                                        barrierDismissible: false,
                                        builder: (_) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );

                                      // 2. Simpan Program Aktif ke Firebase
                                      await firestoreService
                                          .setActiveProgram(uid, {
                                            'programId': prog['id'],
                                            'title': prog['title'],
                                            'category': prog['category'],
                                            'totalDays': prog['totalDays'],
                                            'level': prog['level'],
                                          });

                                      // 3. MAGIC INJECTION (Looping Jadwal)
                                      final today = DateTime.now();
                                      final totalDays =
                                          prog['totalDays'] as int;
                                      final programId = prog['id'];

                                      for (int i = 0; i < totalDays; i++) {
                                        final targetDate = today.add(
                                          Duration(days: i),
                                        );

                                        if (programId == 'diet_60') {
                                          final dietEntry = WorkoutEntry(
                                            id: '',
                                            exerciseName:
                                                'Jalan Santai / Kardio (Hari ${i + 1})',
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

                                          await firestoreService
                                              .addWorkoutEntry(
                                                uid,
                                                targetDate,
                                                dietEntry,
                                              );
                                          await firestoreService
                                              .addWorkoutEntry(
                                                uid,
                                                targetDate,
                                                makanEntry,
                                              );
                                        } else {
                                          final latihan1 = WorkoutEntry(
                                            id: '',
                                            exerciseName:
                                                'Push Up (Hari ${i + 1})',
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
                                            exerciseName:
                                                'Plank (Hari ${i + 1})',
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

                                          await firestoreService
                                              .addWorkoutEntry(
                                                uid,
                                                targetDate,
                                                latihan1,
                                              );
                                          await firestoreService
                                              .addWorkoutEntry(
                                                uid,
                                                targetDate,
                                                latihan2,
                                              );
                                        }
                                      }

                                      if (ctx.mounted) {
                                        Navigator.pop(ctx); // Tutup Loading
                                        ScaffoldMessenger.of(ctx).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '🎉 Program "${prog['title']}" dimulai! Jadwal disiapkan.',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        // 4. Langsung Arahkan ke TrackingScreen
                                        Navigator.push(
                                          ctx,
                                          MaterialPageRoute(
                                            builder: (_) => TrackingScreen(),
                                          ),
                                        );
                                      }
                                    }
                                  },
                          );
                        }, childCount: _programs.length),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final Map<String, dynamic> program;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onStart;
  final bool isActive;

  const _ProgramCard({
    required this.program,
    required this.color,
    required this.onTap,
    required this.onStart,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            program['category'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              program['icon'] as IconData,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              program['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program['desc'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6C757D),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _chip(
                        Icons.timer_outlined,
                        '${program['totalDays']} Hari',
                      ),
                      const SizedBox(width: 8),
                      _chip(Icons.bar_chart, program['level']),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: onStart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive
                              ? Colors.grey.shade300
                              : color,
                          foregroundColor: isActive
                              ? Colors.grey.shade600
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          elevation: isActive ? 0 : 2,
                        ),
                        child: Text(
                          isActive ? 'Aktif' : 'Mulai',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF6C757D)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6C757D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
