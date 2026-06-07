class FitnessProgram {
  final String id;
  final String name; // e.g. Bulking, Cutting
  final String description;
  final int durationDays;

  FitnessProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.durationDays,
  });

  factory FitnessProgram.fromMap(Map<String, dynamic> data, String documentId) {
    return FitnessProgram(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      durationDays: data['durationDays'] ?? 30,
    );
  }
}

class DailyNutrition {
  final String breakfast;
  final String lunch;
  final String dinner;
  final String snack;
  final List<String> doAndDonts;

  DailyNutrition({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snack,
    required this.doAndDonts,
  });

  factory DailyNutrition.fromMap(Map<String, dynamic> data) {
    return DailyNutrition(
      breakfast: data['breakfast'] ?? '',
      lunch: data['lunch'] ?? '',
      dinner: data['dinner'] ?? '',
      snack: data['snack'] ?? '',
      doAndDonts: List<String>.from(data['doAndDonts'] ?? []),
    );
  }
}

class DailyPlan {
  final int day;
  final List<String> exerciseIds; // List of exercise IDs to perform today
  final DailyNutrition nutrition;

  DailyPlan({
    required this.day,
    required this.exerciseIds,
    required this.nutrition,
  });

  factory DailyPlan.fromMap(Map<String, dynamic> data) {
    return DailyPlan(
      day: data['day'] ?? 1,
      exerciseIds: List<String>.from(data['exerciseIds'] ?? []),
      nutrition: DailyNutrition.fromMap(data['nutrition'] ?? {}),
    );
  }
}
