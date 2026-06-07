import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String username;
  const ProfileSetupScreen({super.key, required this.username});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _currentStep = 1;
  final int _totalSteps = 6;
  bool _isLoading = false;

  final _authService = FirebaseAuthService();
  final _firestoreService = FirestoreService();

  // Form Data
  String? _gender;
  final List<String> _focusAreas = [];
  String? _preference;
  String? _fitnessLevel;
  double _activityLevel = 0.5;
  String? _location;

  void _nextStep() {
    if (_currentStep <= _totalSteps) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  void _finish() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final profileData = {
          'gender': _gender,
          'focusAreas': _focusAreas,
          'preference': _preference,
          'fitnessLevel': _fitnessLevel,
          'activityLevel': _activityLevel,
          'location': _location,
        };
        await _firestoreService.saveUserProfile(user.uid, profileData);
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen(username: widget.username)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e'), backgroundColor: Colors.red));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep > _totalSteps) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prevStep),
        title: _currentStep == 6 || _currentStep == 4 ? const Text('Gerak') : null,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _currentStep / _totalSteps,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text('$_currentStep/$_totalSteps', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: _buildCurrentStepContent(),
                ),
              ),
              const SizedBox(height: 16),
              if (_currentStep == 1)
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: _prevStep, child: const Text('Kembali'))),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(onPressed: _gender != null ? _nextStep : null, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Selanjutnya'), SizedBox(width: 8), Icon(Icons.arrow_forward)])),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: _nextStep,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_currentStep == _totalSteps ? 'Selesaikan' : 'Lanjutkan'),
                      if (_currentStep != _totalSteps) const SizedBox(width: 8),
                      if (_currentStep != _totalSteps) const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1: return _buildStep1();
      case 2: return _buildStep2();
      case 3: return _buildStep3();
      case 4: return _buildStep4();
      case 5: return _buildStep5();
      case 6: return _buildStep6();
      default: return const SizedBox();
    }
  }

  // --- STEPS IMPLEMENTATION ---

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Jenis Kelamin Kamu', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1D20))),
        const SizedBox(height: 12),
        const Text('Informasi ini membantu kami menyesuaikan program kebugaran dan target kalori harian yang paling efektif untukmu.', style: TextStyle(fontSize: 14, color: Color(0xFF6C757D))),
        const SizedBox(height: 32),
        _buildGenderCard('Laki-laki', 'assets/images/setup_male.png'),
        const SizedBox(height: 16),
        _buildGenderCard('Perempuan', 'assets/images/setup_female.png'),
      ],
    );
  }

  Widget _buildGenderCard(String title, String imagePath) {
    bool isSelected = _gender == title;
    return GestureDetector(
      onTap: () => setState(() => _gender = title),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: isSelected ? 0.3 : 0.6), BlendMode.darken)),
          border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 3) : null,
        ),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.bottomLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.check, size: 16, color: Theme.of(context).primaryColor),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bagian tubuh mana yang ingin kamu fokuskan?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1D20))),
        const SizedBox(height: 12),
        const Text('Pilih satu atau lebih area untuk mempersonalisasi program latihanmu.', style: TextStyle(fontSize: 14, color: Color(0xFF6C757D))),
        const SizedBox(height: 32),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildFocusCard('Seluruh Tubuh', Icons.accessibility_new),
            _buildFocusCard('Lengan & Bahu', Icons.fitness_center),
            _buildFocusCard('Perut (Abs)', Icons.sports_gymnastics),
            _buildFocusCard('Kaki & Bokong', Icons.directions_run),
          ],
        )
      ],
    );
  }

  Widget _buildFocusCard(String title, IconData icon) {
    bool isSelected = _focusAreas.contains(title);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _focusAreas.remove(title);
          } else {
            _focusAreas.add(title);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F5FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(radius: 40, backgroundColor: Colors.grey.shade200, child: Icon(icon, size: 40, color: Colors.grey.shade700)),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 8, right: 8,
                child: Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Apa preferensi latihanmu?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1D20))),
        const SizedBox(height: 12),
        const Text('Pilih gaya latihan utama untuk membantu kami menyusun program yang paling optimal untuk progres kamu.', style: TextStyle(fontSize: 14, color: Color(0xFF6C757D))),
        const SizedBox(height: 32),
        _buildPrefCard('Fokus Latihan Beban', 'INTENSITAS TINGGI', Icons.fitness_center, 'assets/images/setup_weights.png'),
        const SizedBox(height: 16),
        _buildPrefCard('Sertakan Kardio', 'KETAHANAN & STAMINA', Icons.directions_run, 'assets/images/setup_cardio.png'),
      ],
    );
  }

  Widget _buildPrefCard(String title, String subtitle, IconData icon, String imagePath) {
    bool isSelected = _preference == title;
    return GestureDetector(
      onTap: () => setState(() => _preference = title),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: isSelected ? 0.4 : 0.6), BlendMode.darken)),
          border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 3) : null,
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(subtitle, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? Theme.of(context).primaryColor : Colors.white54, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sedikit lagi tentang fisikmu', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1D20))),
        const SizedBox(height: 12),
        const Text('Data ini membantu Gerak menyusun program yang paling aman dan efektif untukmu.', style: TextStyle(fontSize: 14, color: Color(0xFF6C757D))),
        const SizedBox(height: 32),
        const Text('Tinggi Badan (cm)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(hintText: 'Misal: 170', prefixIcon: Icon(Icons.height), fillColor: Colors.white)),
        const SizedBox(height: 20),
        const Text('Berat Badan (kg)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(hintText: 'Misal: 65', prefixIcon: Icon(Icons.monitor_weight_outlined), fillColor: Colors.white)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Ada cidera di area tertentu?', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
              child: const Text('Opsional', style: TextStyle(fontSize: 10, color: Colors.grey)),
            )
          ],
        ),
        const SizedBox(height: 8),
        TextField(maxLines: 4, decoration: const InputDecoration(hintText: 'Misal: Nyeri lutut kanan saat berlari...', fillColor: Colors.white)),
      ],
    );
  }

  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Beritahu kami tingkat pengalamanmu', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1D20))),
        const SizedBox(height: 12),
        const Text('Langkah 5 dari 7. Personalisasi ini membantu kami menyesuaikan intensitas latihanmu.', style: TextStyle(fontSize: 14, color: Color(0xFF6C757D))),
        const SizedBox(height: 32),
        const Text('Tingkat Fitness', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildFitLevel('Pemula', 'Baru mulai atau lama tidak berlatih.', Icons.directions_walk),
        const SizedBox(height: 12),
        _buildFitLevel('Menengah', 'Berolahraga 1-3 kali seminggu.', Icons.fitness_center),
        const SizedBox(height: 12),
        _buildFitLevel('Lanjutan', 'Rutin berolahraga intens lebih dari 4 kali.', Icons.directions_run),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tingkat Aktivitas Harian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Seberapa aktif kamu di luar sesi olahraga?', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 24),
              Slider(
                value: _activityLevel,
                onChanged: (v) => setState(() => _activityLevel = v),
                activeColor: Theme.of(context).primaryColor,
                inactiveColor: Colors.grey.shade300,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sangat jarang\nbergerak', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('Sangat\naktif', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFitLevel(String title, String desc, IconData icon) {
    bool isSelected = _fitnessLevel == title;
    return GestureDetector(
      onTap: () => setState(() => _fitnessLevel = title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F5FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isSelected ? const Color(0xFFD0DFFF) : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade700)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12))])),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildStep6() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Di mana kamu akan berlatih?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1D20))),
        const SizedBox(height: 12),
        const Text('Pilih preferensi lokasi latihan utama kamu.', style: TextStyle(fontSize: 14, color: Color(0xFF6C757D))),
        const SizedBox(height: 32),
        _buildLocCard('Gym', 'assets/images/setup_gym_loc.png'),
        const SizedBox(height: 16),
        _buildLocCard('Latihan di Rumah', 'assets/images/setup_home_loc.png'),
      ],
    );
  }

  Widget _buildLocCard(String title, String imagePath) {
    bool isSelected = _location == title;
    return GestureDetector(
      onTap: () => setState(() => _location = title),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: isSelected ? 0.3 : 0.6), BlendMode.darken)),
          border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 3) : null,
        ),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.bottomLeft,
        child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Gerak', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(height: 60),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(width: 200, height: 200, decoration: BoxDecoration(color: const Color(0xFFE5EDFF), shape: BoxShape.circle)),
                  Container(width: 140, height: 140, decoration: BoxDecoration(color: const Color(0xFFB5CCFF), shape: BoxShape.circle)),
                  Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  Icon(Icons.check_circle, size: 60, color: Theme.of(context).primaryColor),
                ],
              ),
              const SizedBox(height: 40),
              const Text('Program Kamu Telah Siap!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text('Kami telah menyusun jadwal latihan dan nutrisi yang pas untukmu.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
              ),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _finish, 
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Buka Dashboard'), SizedBox(width: 8), Icon(Icons.arrow_forward)])
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
