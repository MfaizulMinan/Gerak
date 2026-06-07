import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../../models/workout_entry.dart';
import '../../services/firestore_service.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _firestoreService = FirestoreService();
  late final ConfettiController _confettiController;

  DateTime _selectedDate = DateTime.now();
  String? _uid;

  // Lottie URLs untuk panduan gerakan
  static const Map<String, String> _lottieUrls = {
    'Push Up': 'https://assets2.lottiefiles.com/packages/lf20_msnmnh1b.json',
    'Squat': 'https://assets2.lottiefiles.com/packages/lf20_bhebjzpu.json',
    'Plank': 'https://assets3.lottiefiles.com/packages/lf20_sz8jkxb9.json',
    'default': 'https://assets4.lottiefiles.com/packages/lf20_1ynlqws2.json',
  };

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _uid = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  String get _formattedDate {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = days[_selectedDate.weekday - 1];
    final month = months[_selectedDate.month - 1];
    return '$day, ${_selectedDate.day} $month ${_selectedDate.year}';
  }

  void _previousDay() => setState(
    () => _selectedDate = _selectedDate.subtract(const Duration(days: 1)),
  );
  void _nextDay() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (_selectedDate.isBefore(
      DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
    )) {
      setState(
        () => _selectedDate = _selectedDate.add(const Duration(days: 1)),
      );
    }
  }

  void _showAddExerciseDialog([WorkoutEntry? existing]) {
    final Map<String, String> dataGerakan = {
      'Push Up': 'Dada, Trisep, Bahu Depan',
      'Squat': 'Paha Depan, Glutes (Bokong)',
      'Plank': 'Perut (Core)',
      'Pull Up': 'Punggung, Bisep',
      'Sit Up': 'Perut',
      'Lunges': 'Paha Depan, Hamstring',
    };

    String? selectedGerakan = existing?.exerciseName;

    if (selectedGerakan != null && !dataGerakan.containsKey(selectedGerakan)) {
      selectedGerakan = null;
    }

    final setsCtrl = TextEditingController(
      text: (existing?.sets ?? 3).toString(),
    );
    final repsCtrl = TextEditingController(
      text: (existing?.repsPerSet ?? 10).toString(),
    );
    final restCtrl = TextEditingController(
      text: (existing?.restSeconds ?? 60).toString(),
    );
    final muscleCtrl = TextEditingController(
      text: existing?.targetMuscle ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        existing == null ? 'Tambah Gerakan' : 'Edit Gerakan',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: selectedGerakan,
                    decoration: const InputDecoration(
                      labelText: 'Nama Gerakan *',
                      hintText: 'Pilih Gerakan',
                    ),
                    items: dataGerakan.keys.map((String key) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text(key),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setModalState(() {
                        selectedGerakan = newValue;
                        if (newValue != null) {
                          muscleCtrl.text = dataGerakan[newValue] ?? '';
                        }
                      });
                    },
                    validator: (v) => v == null ? 'Wajib dipilih' : null,
                  ),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: muscleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Otot Target',
                      hintText: 'Contoh: Dada, Trisep',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: setsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Set *'),
                          validator: (v) => v!.isEmpty ? 'Wajib' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: repsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Rep/Set *',
                          ),
                          validator: (v) => v!.isEmpty ? 'Wajib' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: restCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Istirahat (s)',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate() || _uid == null) {
                          return;
                        }
                        Navigator.pop(ctx);

                        final lottie =
                            _lottieUrls[selectedGerakan] ??
                            _lottieUrls['default']!;
                        if (existing == null) {
                          final entry = WorkoutEntry(
                            id: '',
                            exerciseName: selectedGerakan!,
                            sets: int.tryParse(setsCtrl.text) ?? 3,
                            repsPerSet: int.tryParse(repsCtrl.text) ?? 10,
                            restSeconds: int.tryParse(restCtrl.text) ?? 60,
                            isCompleted: false,
                            lottieUrl: lottie,
                            targetMuscle: muscleCtrl.text.trim(),
                            caloriesPerSet: 15,
                            createdAt: DateTime.now(),
                          );
                          await _firestoreService.addWorkoutEntry(
                            _uid!,
                            _selectedDate,
                            entry,
                          );
                        } else {
                          await _firestoreService.updateWorkoutEntry(
                            _uid!,
                            _selectedDate,
                            existing.id,
                            {
                              'exerciseName': selectedGerakan!,
                              'sets':
                                  int.tryParse(setsCtrl.text) ?? existing.sets,
                              'repsPerSet':
                                  int.tryParse(repsCtrl.text) ??
                                  existing.repsPerSet,
                              'restSeconds':
                                  int.tryParse(restCtrl.text) ??
                                  existing.restSeconds,
                              'targetMuscle': muscleCtrl.text.trim(),
                            },
                          );
                        }
                      },
                      child: Text(
                        existing == null
                            ? 'Tambah Gerakan'
                            : 'Simpan Perubahan',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openExerciseDetail(WorkoutEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ExerciseDetailScreen(entry: entry)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          CustomScrollView(
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
                          Theme.of(context).primaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Tracking Latihan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isToday ? 'Hari ini' : 'Riwayat',
                              style: const TextStyle(
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

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _previousDay,
                            icon: const Icon(Icons.chevron_left),
                            color: Theme.of(context).primaryColor,
                          ),
                          Column(
                            children: [
                              Text(
                                _formattedDate,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              if (_isToday)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Hari ini',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          IconButton(
                            onPressed: _nextDay,
                            icon: const Icon(Icons.chevron_right),
                            color: _isToday
                                ? Colors.grey.shade300
                                : Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                    _WeekStripCalendar(
                      uid: _uid,
                      selectedDate: _selectedDate,
                      onDateSelected: (d) => setState(() => _selectedDate = d),
                      firestoreService: _firestoreService,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              if (_uid != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: StreamBuilder<List<WorkoutEntry>>(
                    stream: _firestoreService.getWorkoutEntriesStream(
                      _uid!,
                      _selectedDate,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      }

                      final entries = snapshot.data ?? [];

                      if (entries.isEmpty) {
                        return SliverToBoxAdapter(child: _buildEmptyState());
                      }

                      final done = entries.where((e) => e.isCompleted).length;
                      final allDone = done == entries.length;
                      if (allDone && done > 0) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _confettiController.play();
                        });
                      }

                      return SliverMainAxisGroup(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                _SummaryCard(total: entries.length, done: done),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                          _SliverExerciseAnimatedList(
                            entries: entries,
                            uid: _uid!,
                            selectedDate: _selectedDate,
                            isToday: _isToday,
                            firestoreService: _firestoreService,
                            onEdit: (entry) => _showAddExerciseDialog(entry),
                            onOpenDetail: (entry) => _openExerciseDetail(entry),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.2,
              colors: const [
                Color(0xFF4CAF50),
                Color(0xFF2196F3),
                Color(0xFFFFC107),
                Color(0xFFE91E63),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isToday
          ? FloatingActionButton.extended(
              onPressed: () => _showAddExerciseDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Gerakan'),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _isToday
                ? 'Belum ada latihan hari ini'
                : 'Tidak ada catatan latihan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isToday
                ? 'Ketuk tombol + untuk mulai mencatat'
                : 'Pilih tanggal lain untuk melihat riwayat',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}

class _SliverExerciseAnimatedList extends StatefulWidget {
  final List<WorkoutEntry> entries;
  final String uid;
  final DateTime selectedDate;
  final bool isToday;
  final FirestoreService firestoreService;
  final void Function(WorkoutEntry) onEdit;
  final void Function(WorkoutEntry) onOpenDetail;

  const _SliverExerciseAnimatedList({
    required this.entries,
    required this.uid,
    required this.selectedDate,
    required this.isToday,
    required this.firestoreService,
    required this.onEdit,
    required this.onOpenDetail,
  });

  @override
  State<_SliverExerciseAnimatedList> createState() => _SliverExerciseAnimatedListState();
}

class _SliverExerciseAnimatedListState extends State<_SliverExerciseAnimatedList> {
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();
  final List<WorkoutEntry> _list = [];
  final Set<String> _dismissedIds = {};

  @override
  void initState() {
    super.initState();
    _list.addAll(widget.entries);
  }

  @override
  void didUpdateWidget(covariant _SliverExerciseAnimatedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncLists(widget.entries);
  }

  void _syncLists(List<WorkoutEntry> newEntries) {
    // 1. Cari item yang dihapus (iterasi mundur agar indeks aman)
    for (int i = _list.length - 1; i >= 0; i--) {
      final oldItem = _list[i];
      final exists = newEntries.any((item) => item.id == oldItem.id);
      if (!exists) {
        final isDismissed = _dismissedIds.contains(oldItem.id);
        _list.removeAt(i);

        if (isDismissed) {
          _listKey.currentState?.removeItem(
            i,
            (context, animation) => const SizedBox.shrink(),
            duration: Duration.zero,
          );
          _dismissedIds.remove(oldItem.id);
        } else {
          final removedItem = oldItem;
          _listKey.currentState?.removeItem(
            i,
            (context, animation) => _buildRemovedItem(removedItem, animation),
            duration: const Duration(milliseconds: 300),
          );
        }
      }
    }

    // 2. Cari item yang ditambahkan atau diperbarui
    for (int i = 0; i < newEntries.length; i++) {
      final newItem = newEntries[i];
      final oldIndex = _list.indexWhere((item) => item.id == newItem.id);

      if (oldIndex == -1) {
        int insertIndex = i;
        if (insertIndex > _list.length) {
          insertIndex = _list.length;
        }
        _list.insert(insertIndex, newItem);
        _listKey.currentState?.insertItem(
          insertIndex,
          duration: const Duration(milliseconds: 300),
        );
      } else {
        final oldItem = _list[oldIndex];
        if (oldItem.isCompleted != newItem.isCompleted ||
            oldItem.exerciseName != newItem.exerciseName ||
            oldItem.sets != newItem.sets ||
            oldItem.repsPerSet != newItem.repsPerSet ||
            oldItem.restSeconds != newItem.restSeconds ||
            oldItem.targetMuscle != newItem.targetMuscle) {
          setState(() {
            _list[oldIndex] = newItem;
          });
        }
      }
    }
  }

  Widget _buildRemovedItem(WorkoutEntry entry, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 0.0,
      child: FadeTransition(
        opacity: animation,
        child: _buildTile(entry, -1, isRemoving: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: _listKey,
      initialItemCount: _list.length,
      itemBuilder: (context, index, animation) {
        final entry = _list[index];
        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOut)),
          ),
          child: FadeTransition(
            opacity: animation,
            child: _buildTile(entry, index),
          ),
        );
      },
    );
  }

  Widget _buildTile(WorkoutEntry entry, int index, {bool isRemoving = false}) {
    final tile = Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: entry.isCompleted
            ? Border.all(color: Colors.green.shade300, width: 2)
            : Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: GestureDetector(
          onTap: isRemoving ? null : () => widget.onOpenDetail(entry),
          child: Hero(
            tag: 'exercise_${entry.id}',
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: entry.isCompleted
                    ? Colors.green.shade50
                    : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                entry.isCompleted ? Icons.check_circle : Icons.fitness_center,
                color: entry.isCompleted
                    ? Colors.green
                    : Theme.of(context).primaryColor,
                size: 28,
              ),
            ),
          ),
        ),
        title: Text(
          entry.exerciseName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            decoration: entry.isCompleted ? TextDecoration.lineThrough : null,
            color: entry.isCompleted ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _pillInfo('${entry.sets} Set', Icons.layers),
                const SizedBox(width: 8),
                _pillInfo('${entry.repsPerSet} Rep', Icons.repeat),
                const SizedBox(width: 8),
                _pillInfo('${entry.restSeconds}s', Icons.timer_outlined),
              ],
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isToday && !isRemoving)
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                onPressed: () => widget.onEdit(entry),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isRemoving
                  ? null
                  : () async {
                      final newVal = !entry.isCompleted;
                      await widget.firestoreService.toggleWorkoutComplete(
                        widget.uid,
                        widget.selectedDate,
                        entry.id,
                        newVal,
                      );
                      if (newVal && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '🎉 "${entry.exerciseName}" selesai!',
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: entry.isCompleted
                      ? Colors.green
                      : Colors.transparent,
                  border: Border.all(
                    color: entry.isCompleted
                        ? Colors.green
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: entry.isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );

    if (isRemoving) return tile;

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Gerakan?'),
            content: Text('Hapus "${entry.exerciseName}" dari log?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        _dismissedIds.add(entry.id);
        await widget.firestoreService.deleteWorkoutEntry(
          widget.uid,
          widget.selectedDate,
          entry.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${entry.exerciseName}" dihapus'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: tile,
    );
  }

  Widget _pillInfo(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF3B82F6)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int total;
  final int done;
  const _SummaryCard({required this.total, required this.done});

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$done / $total Gerakan Selesai',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${(percent * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStripCalendar extends StatefulWidget {
  final String? uid;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final FirestoreService firestoreService;

  const _WeekStripCalendar({
    required this.uid,
    required this.selectedDate,
    required this.onDateSelected,
    required this.firestoreService,
  });

  @override
  State<_WeekStripCalendar> createState() => _WeekStripCalendarState();
}

class _WeekStripCalendarState extends State<_WeekStripCalendar> {
  List<String> _workoutDates = [];

  @override
  void initState() {
    super.initState();
    _loadWorkoutDates();
  }

  Future<void> _loadWorkoutDates() async {
    if (widget.uid == null) return;
    final dates = await widget.firestoreService.getWorkoutDatesThisMonth(
      widget.uid!,
    );
    if (mounted) setState(() => _workoutDates = dates);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.subtract(Duration(days: 3 - i)));

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((date) {
          final isSelected =
              date.year == widget.selectedDate.year &&
              date.month == widget.selectedDate.month &&
              date.day == widget.selectedDate.day;
          final isToday =
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
          final dateStr =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          final hasWorkout = _workoutDates.contains(dateStr);

          const dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
          final dayName = dayNames[date.weekday - 1];

          return GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : (isToday
                          ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.08)
                          : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isToday
                                ? Theme.of(context).primaryColor
                                : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasWorkout
                          ? (isSelected ? Colors.white : Colors.green)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ExerciseDetailScreen extends StatelessWidget {
  final WorkoutEntry entry;
  const _ExerciseDetailScreen({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Hero(
                      tag: 'exercise_${entry.id}',
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      entry.exerciseName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (entry.targetMuscle.isNotEmpty)
                      Text(
                        entry.targetMuscle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _statCard('${entry.sets}', 'Set', Icons.layers),
                      const SizedBox(width: 12),
                      _statCard('${entry.repsPerSet}', 'Rep/Set', Icons.repeat),
                      const SizedBox(width: 12),
                      _statCard(
                        '${entry.restSeconds}s',
                        'Istirahat',
                        Icons.timer_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Panduan Gerakan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: entry.lottieUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _LottieWidget(url: entry.lottieUrl),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_circle_outline,
                                  size: 60,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Animasi panduan tersedia\nsaat perangkat online',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tips',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• Fokus pada teknik yang benar daripada jumlah repetisi\n'
                          '• Napas teratur: hembuskan saat kontraksi\n'
                          '• Istirahat sesuai interval agar otot pulih optimal\n'
                          '• Jika terasa nyeri, segera berhenti dan konsultasikan',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.7,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF3B82F6)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _LottieWidget extends StatelessWidget {
  final String url;
  const _LottieWidget({required this.url});

  @override
  Widget build(BuildContext context) {
    try {
      return _buildLottie();
    } catch (_) {
      return const Center(
        child: Icon(Icons.fitness_center, size: 60, color: Colors.grey),
      );
    }
  }

  Widget _buildLottie() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: const Color(0xFFF8F9FF),
          child: Center(
            child: Icon(
              Icons.self_improvement,
              size: 80,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
            ),
          ),
        );
      },
    );
  }
}
