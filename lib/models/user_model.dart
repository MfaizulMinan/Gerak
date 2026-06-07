class UserModel {
  final String uid;
  final String name;
  final String email;
  final int age;
  final double height; // cm
  final double weight; // kg
  final String gender;
  final String photoUrl;
  final bool isProfileSetupCompleted;
  final int streak;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    this.photoUrl = '',
    this.isProfileSetupCompleted = false,
    this.streak = 0,
  });

  /// Hitung BMI: Berat (kg) / (Tinggi (m))²
  double get bmi {
    if (height <= 0) return 0;
    final heightM = height / 100;
    return weight / (heightM * heightM);
  }

  /// Kategori BMI berdasarkan WHO
  String get bmiCategory {
    final b = bmi;
    if (b < 18.5) return 'Kekurangan Berat';
    if (b < 25.0) return 'Normal';
    if (b < 30.0) return 'Kelebihan Berat';
    return 'Obesitas';
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      age: data['age'] ?? 0,
      height: (data['height'] ?? 0).toDouble(),
      weight: (data['weight'] ?? 0).toDouble(),
      gender: data['gender'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      isProfileSetupCompleted: data['isProfileSetupCompleted'] ?? false,
      streak: data['streak'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'photoUrl': photoUrl,
      'isProfileSetupCompleted': isProfileSetupCompleted,
      'streak': streak,
    };
  }

  UserModel copyWith({
    String? name,
    int? age,
    double? height,
    double? weight,
    String? gender,
    String? photoUrl,
    int? streak,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      isProfileSetupCompleted: isProfileSetupCompleted,
      streak: streak ?? this.streak,
    );
  }
}
