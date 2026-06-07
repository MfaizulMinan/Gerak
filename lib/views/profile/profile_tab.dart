import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gerak/views/progress/weight_history_screen.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/firebase_auth_service.dart';
import '../auth/login_screen.dart';

// Catatan: Sesuaikan path import di bawah ini dengan struktur folder project Anda
import 'package:gerak/views/notifications/reminder_screen.dart';
import 'package:gerak/views/support/help_screen.dart'; // Folder diganti ke support

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _firestoreService = FirestoreService();
  final _authService = FirebaseAuthService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Center(child: Text('Tidak terautentikasi'));
    }

    return StreamBuilder<Map<String, dynamic>?>(
      stream: _firestoreService.getUserProfileStream(_uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data;
        if (data == null) {
          return const Center(child: Text('Profil tidak ditemukan'));
        }

        final user = UserModel.fromMap(data, _uid);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: CustomScrollView(
            slivers: [
              // Profile header
              SliverToBoxAdapter(child: _buildHeader(user)),

              // BMI & Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    children: [
                      _buildBmiCard(user),
                      const SizedBox(height: 16),
                      _buildStatsRow(user),
                      const SizedBox(height: 24),
                      _buildWeightUpdateCard(user),
                      const SizedBox(height: 24),
                      _buildMenuCard(context, user),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.orangeAccent,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                '${user.streak} hari streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBmiCard(UserModel user) {
    final bmi = user.bmi;
    final category = user.bmiCategory;
    Color bmiColor;
    if (bmi < 18.5) {
      bmiColor = Colors.blue;
    } else if (bmi < 25) {
      bmiColor = Colors.green;
    } else if (bmi < 30) {
      bmiColor = Colors.orange;
    } else {
      bmiColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.monitor_heart_outlined, color: bmiColor, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Body Mass Index (BMI)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C757D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                bmi > 0 ? bmi.toStringAsFixed(1) : '-',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: bmiColor,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: bmiColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: bmiColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.weight} kg | ${user.height} cm',
                    style: const TextStyle(
                      color: Color(0xFF6C757D),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final double percent = ((bmi.clamp(10, 40) - 10) / 30);
              final double indicatorPosition = (percent * barWidth) - 8;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [
                          Colors.blue,
                          Colors.green,
                          Colors.orange,
                          Colors.red,
                        ],
                      ),
                    ),
                  ),
                  if (bmi > 0)
                    Positioned(
                      left: indicatorPosition.clamp(0, barWidth - 16),
                      top: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: bmiColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('<18.5', style: TextStyle(fontSize: 10, color: Colors.blue)),
              Text(
                '18.5-24.9',
                style: TextStyle(fontSize: 10, color: Colors.green),
              ),
              Text(
                '25-29.9',
                style: TextStyle(fontSize: 10, color: Colors.orange),
              ),
              Text('>30', style: TextStyle(fontSize: 10, color: Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserModel user) {
    return Row(
      children: [
        _statCard(user.age.toString(), 'Usia', 'tahun', Icons.cake_outlined),
        const SizedBox(width: 12),
        _statCard(user.height.toStringAsFixed(0), 'Tinggi', 'cm', Icons.height),
        const SizedBox(width: 12),
        _statCard(
          user.weight.toStringAsFixed(1),
          'Berat',
          'kg',
          Icons.monitor_weight_outlined,
        ),
      ],
    );
  }

  Widget _statCard(String value, String label, String unit, IconData icon) {
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
            Icon(icon, size: 22, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              unit,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6C757D)),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6C757D)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightUpdateCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            'Update Berat Badan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Berat saat ini: ${user.weight} kg',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6C757D)),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showWeightUpdateDialog(user.weight),
            icon: const Icon(Icons.add),
            label: const Text('Catat Berat Sekarang'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          _menuItem(
            Icons.edit_outlined,
            'Edit Profil',
            'Ubah data pribadi & fisik',
            () => _showEditProfileDialog(user),
          ),
          _divider(),
          _menuItem(
            Icons.bar_chart_outlined,
            'Riwayat Berat Badan',
            'Lihat perubahan berat badan',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WeightHistoryScreen()),
              );
            },
          ),
          _divider(),
          _menuItem(
            Icons.notifications_outlined,
            'Pengingat Latihan',
            'Atur notifikasi harian',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReminderScreen()),
              );
            },
          ),
          _divider(),
          _menuItem(
            Icons.help_outline,
            'Bantuan',
            'FAQ & Hubungi dukungan',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpScreen()),
              );
            },
          ),
          _divider(),
          _menuItem(
            Icons.logout,
            'Logout',
            'Keluar dari akun',
            _logout,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.shade50
              : Theme.of(context).primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D)),
      ),
      trailing: isDestructive
          ? null
          : const Icon(Icons.chevron_right, color: Color(0xFFB0BEC5)),
      onTap: onTap,
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 72, endIndent: 16);

  void _showWeightUpdateDialog(double currentWeight) {
    final ctrl = TextEditingController(text: currentWeight.toStringAsFixed(1));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Berat Badan'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Berat badan (kg)',
            suffixText: 'kg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final weight = double.tryParse(ctrl.text);
              if (weight != null && weight > 0 && _uid != null) {
                Navigator.pop(ctx);

                await _firestoreService.saveWeightEntry(_uid!, weight);
                await _firestoreService.updateUserProfile(_uid!, {
                  'weight': weight,
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Berat badan diperbarui: $weight kg 🎉'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(UserModel user) {
    final nameCtrl = TextEditingController(text: user.name);
    final ageCtrl = TextEditingController(text: user.age.toString());
    final heightCtrl = TextEditingController(
      text: user.height.toStringAsFixed(0),
    );
    final weightCtrl = TextEditingController(
      text: user.weight.toStringAsFixed(1),
    );
    String gender = user.gender;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Profil',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Usia (tahun)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: heightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tinggi (cm)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: weightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Berat (kg)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: ['Laki-laki', 'Perempuan'].map((g) {
                  final sel = gender == g;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => gender = g),
                      child: Container(
                        margin: EdgeInsets.only(
                          right: g == 'Laki-laki' ? 8 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: sel
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            g,
                            style: TextStyle(
                              color: sel ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_uid == null) return;
                    Navigator.pop(ctx);
                    await _firestoreService.updateUserProfile(_uid!, {
                      'name': nameCtrl.text.trim(),
                      'age': int.tryParse(ageCtrl.text) ?? user.age,
                      'height': double.tryParse(heightCtrl.text) ?? user.height,
                      'weight': double.tryParse(weightCtrl.text) ?? user.weight,
                      'gender': gender,
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil berhasil diperbarui! ✅'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FUNGSI LOGOUT (SUDAH DIPERBAIKI)
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
