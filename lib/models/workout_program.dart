class Exercise {
  final String name;
  final String durationOrReps;
  const Exercise(this.name, this.durationOrReps);
}

class WorkoutProgram {
  final String id;
  final String title;
  final String focus;
  final String tag;
  final String imagePath;
  final String description;
  final int durationMinutes;
  final String difficulty;
  final List<Exercise> exercises;

  const WorkoutProgram({
    required this.id,
    required this.title,
    required this.focus,
    required this.tag,
    required this.imagePath,
    required this.description,
    required this.durationMinutes,
    required this.difficulty,
    this.exercises = const [
      Exercise('Pemanasan (Jumping Jacks)', '2 Menit'),
      Exercise('Push Up', '3 Set x 15 Repetisi'),
      Exercise('Plank', '3 Set x 60 Detik'),
      Exercise('Squat Jump', '3 Set x 20 Repetisi'),
      Exercise('Pendinginan', '3 Menit'),
    ],
  });
}

final List<WorkoutProgram> allPrograms = [
  const WorkoutProgram(
    id: 'p1',
    title: 'Bakar Lemak Ekstra',
    focus: 'Seluruh Tubuh',
    tag: 'HIIT',
    imagePath: 'assets/images/program_hiit.png',
    description: 'Latihan interval intensitas tinggi untuk membakar kalori secara maksimal dalam waktu singkat.',
    durationMinutes: 20,
    difficulty: 'Lanjutan',
  ),
  const WorkoutProgram(
    id: 'p2',
    title: 'Kekuatan Absolut',
    focus: 'Otot Lengan & Dada',
    tag: 'Strength',
    imagePath: 'assets/images/program_strength.png',
    description: 'Fokus pada pembentukan otot tubuh bagian atas menggunakan beban tubuh atau dumbbell.',
    durationMinutes: 30,
    difficulty: 'Menengah',
  ),
  const WorkoutProgram(
    id: 'p3',
    title: 'Ketenangan Jiwa Raga',
    focus: 'Fleksibilitas',
    tag: 'Yoga',
    imagePath: 'assets/images/program_yoga.png',
    description: 'Rangkaian pose peregangan untuk melemaskan otot tegang dan menenangkan pikiran.',
    durationMinutes: 15,
    difficulty: 'Pemula',
  ),
  const WorkoutProgram(
    id: 'p4',
    title: 'Kardio Udara Segar',
    focus: 'Stamina',
    tag: 'Cardio',
    imagePath: 'assets/images/program_cardio_run.png',
    description: 'Tingkatkan kapasitas paru-paru dan daya tahan jantung dengan sesi kardio dinamis.',
    durationMinutes: 25,
    difficulty: 'Menengah',
  ),
  const WorkoutProgram(
    id: 'p5',
    title: 'Gerak Cepat 15 Menit',
    focus: 'Kardio Ringan',
    tag: 'Tanpa Alat',
    imagePath: 'assets/images/onboard_neon_1.png',
    description: 'Latihan kilat tanpa alat apapun, cocok dilakukan di kamar sebelum mandi pagi.',
    durationMinutes: 15,
    difficulty: 'Pemula',
  ),
  const WorkoutProgram(
    id: 'p6',
    title: 'Peregangan Pagi',
    focus: 'Fleksibilitas',
    tag: 'Tanpa Alat',
    imagePath: 'assets/images/onboard_neon_2.png',
    description: 'Mulai hari dengan meregangkan tulang belakang dan otot utama agar segar seharian.',
    durationMinutes: 10,
    difficulty: 'Pemula',
  ),
];
