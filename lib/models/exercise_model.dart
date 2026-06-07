class Exercise {
  final String id;
  final String name;
  final String description;
  final String targetMuscle;
  final int caloriesPerSet;
  final String urlLottie; // URL file JSON Lottie

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.targetMuscle,
    required this.caloriesPerSet,
    required this.urlLottie,
  });

  factory Exercise.fromMap(Map<String, dynamic> data, String documentId) {
    return Exercise(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      targetMuscle: data['targetMuscle'] ?? '',
      caloriesPerSet: data['caloriesPerSet'] ?? 0,
      urlLottie: data['urlLottie'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'targetMuscle': targetMuscle,
      'caloriesPerSet': caloriesPerSet,
      'urlLottie': urlLottie,
    };
  }
}
