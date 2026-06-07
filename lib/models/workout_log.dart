class WorkoutLog {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final int sets;
  final int repsPerSet;
  final int restDurationSeconds;
  final bool isCompleted;
  final DateTime date;

  WorkoutLog({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.repsPerSet,
    required this.restDurationSeconds,
    required this.isCompleted,
    required this.date,
  });

  factory WorkoutLog.fromMap(Map<String, dynamic> data, String documentId) {
    return WorkoutLog(
      id: documentId,
      exerciseId: data['exerciseId'] ?? '',
      exerciseName: data['exerciseName'] ?? '',
      sets: data['sets'] ?? 0,
      repsPerSet: data['repsPerSet'] ?? 0,
      restDurationSeconds: data['restDurationSeconds'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      date: data['date'] != null ? data['date'].toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets,
      'repsPerSet': repsPerSet,
      'restDurationSeconds': restDurationSeconds,
      'isCompleted': isCompleted,
      'date': date,
    };
  }
}
