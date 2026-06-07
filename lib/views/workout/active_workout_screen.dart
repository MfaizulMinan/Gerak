import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import '../../models/workout_program.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final WorkoutProgram program;
  const ActiveWorkoutScreen({super.key, required this.program});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late int _timeLeft;
  bool _isPaused = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.program.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _timeLeft > 0) {
        setState(() => _timeLeft--);
      } else if (_timeLeft <= 0) {
        timer.cancel();
        _showCompletionDialog();
      }
    });
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Latihan Selesai! 🎉'),
        content: const Text('Kerja bagus! Data latihan Anda telah disimpan.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to Detail
              Navigator.pop(context); // Go back to Dashboard
            },
            child: const Text('Kembali ke Dashboard'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.program.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Akhiri Latihan?'),
                  content: const Text('Latihan belum selesai. Yakin ingin keluar?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c), child: const Text('Batal')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(c);
                        Navigator.pop(context);
                      },
                      child: const Text('Ya, Keluar', style: TextStyle(color: Colors.red)),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Lottie Animation
            Expanded(
              child: Center(
                child: Lottie.network(
                  'https://assets4.lottiefiles.com/packages/lf20_1ynlqws2.json', // Sample workout animation
                  animate: !_isPaused,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.directions_run, size: 100, color: Theme.of(context).primaryColor);
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            Text(
              'Gerakan Saat Ini',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              widget.program.exercises.first.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            ),
            
            const SizedBox(height: 40),
            // Timer Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE5EDFF),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                _formattedTime,
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  Icons.skip_previous_rounded,
                  Colors.grey.shade200,
                  Colors.black,
                  () {},
                ),
                const SizedBox(width: 24),
                _buildControlButton(
                  _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  Theme.of(context).primaryColor,
                  Colors.white,
                  _togglePause,
                  size: 80,
                  iconSize: 40,
                ),
                const SizedBox(width: 24),
                _buildControlButton(
                  Icons.skip_next_rounded,
                  Colors.grey.shade200,
                  Colors.black,
                  () {},
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, Color bgColor, Color iconColor, VoidCallback onTap, {double size = 60, double iconSize = 30}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: bgColor == Colors.white || bgColor == Colors.grey.shade200 ? null : [
            BoxShadow(color: bgColor.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}
