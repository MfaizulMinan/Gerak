/// Model untuk satu gerakan latihan dalam log harian
class WorkoutEntry {
  final String id; // Firestore document ID
  final String exerciseName;
  final int sets;
  final int repsPerSet;
  final int restSeconds;
  final bool isCompleted;
  final String lottieUrl; // URL animasi Lottie panduan gerakan
  final String targetMuscle;
  final int caloriesPerSet;
  final DateTime createdAt;

  WorkoutEntry({
    required this.id,
    required this.exerciseName,
    required this.sets,
    required this.repsPerSet,
    required this.restSeconds,
    required this.isCompleted,
    this.lottieUrl = '',
    this.targetMuscle = '',
    this.caloriesPerSet = 0,
    required this.createdAt,
  });

  int get totalCalories => caloriesPerSet * sets;

  WorkoutEntry copyWith({
    bool? isCompleted,
    int? sets,
    int? repsPerSet,
    int? restSeconds,
  }) {
    return WorkoutEntry(
      id: id,
      exerciseName: exerciseName,
      sets: sets ?? this.sets,
      repsPerSet: repsPerSet ?? this.repsPerSet,
      restSeconds: restSeconds ?? this.restSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      lottieUrl: lottieUrl,
      targetMuscle: targetMuscle,
      caloriesPerSet: caloriesPerSet,
      createdAt: createdAt,
    );
  }

  factory WorkoutEntry.fromMap(Map<String, dynamic> data, String docId) {
    return WorkoutEntry(
      id: docId,
      exerciseName: data['exerciseName'] ?? '',
      sets: data['sets'] ?? 3,
      repsPerSet: data['repsPerSet'] ?? 10,
      restSeconds: data['restSeconds'] ?? 60,
      isCompleted: data['isCompleted'] ?? false,
      lottieUrl: data['lottieUrl'] ?? '',
      targetMuscle: data['targetMuscle'] ?? '',
      caloriesPerSet: data['caloriesPerSet'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseName': exerciseName,
      'sets': sets,
      'repsPerSet': repsPerSet,
      'restSeconds': restSeconds,
      'isCompleted': isCompleted,
      'lottieUrl': lottieUrl,
      'targetMuscle': targetMuscle,
      'caloriesPerSet': caloriesPerSet,
      'createdAt': createdAt,
    };
  }
}
