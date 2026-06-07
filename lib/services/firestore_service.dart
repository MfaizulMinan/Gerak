import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_entry.dart';
import '../models/chat_message.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── PROGRAM LATIHAN ───────────────────────────────────────────────────────

  // Fungsi untuk membatalkan/menghapus program yang diikuti
  Future<void> batalMulaiProgram(String uid) async {
    try {
      // Menghapus data program aktif di document user dengan mengubahnya jadi null
      await _db.collection('users').doc(uid).update({
        'activeProgramId': null,
        'programStartDate': null,
      });
    } catch (e) {
      print("Gagal membatalkan program: $e");
    }
  }

  // ─── PROFIL PENGGUNA ────────────────────────────────────────────────────────

  Future<void> saveUserProfile(
    String uid,
    Map<String, dynamic> profileData,
  ) async {
    await _db.collection('users').doc(uid).set({
      ...profileData,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) return doc.data();
    return null;
  }

  Stream<Map<String, dynamic>?> getUserProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) return doc.data();
      return null;
    });
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── RIWAYAT BERAT BADAN ────────────────────────────────────────────────────

  Future<void> saveWeightEntry(String uid, double weight) async {
    final dateStr = _dateStr(DateTime.now());
    await _db
        .collection('users')
        .doc(uid)
        .collection('weightHistory')
        .doc(dateStr)
        .set({'weight': weight, 'date': FieldValue.serverTimestamp()});
    // Update berat di profil juga
    await updateUserProfile(uid, {'weight': weight});
  }

  Future<List<Map<String, dynamic>>> getWeightHistory(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('weightHistory')
        .orderBy('date', descending: false)
        .limit(30)
        .get();
    return snapshot.docs.map((d) => {'date': d.id, ...d.data()}).toList();
  }

  // ─── WORKOUT LOG (CRUD) ─────────────────────────────────────────────────────

  String _dateStr(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  CollectionReference<Map<String, dynamic>> _exercisesRef(
    String uid,
    DateTime date,
  ) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('workoutLogs')
        .doc(_dateStr(date))
        .collection('exercises');
  }

  /// Stream daftar latihan untuk tanggal tertentu
  Stream<List<WorkoutEntry>> getWorkoutEntriesStream(
    String uid,
    DateTime date,
  ) {
    return _exercisesRef(uid, date)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => WorkoutEntry.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  /// Tambah gerakan baru (Create)
  Future<void> addWorkoutEntry(
    String uid,
    DateTime date,
    WorkoutEntry entry,
  ) async {
    await _exercisesRef(uid, date).add(entry.toMap());
    // Tandai tanggal ini sebagai hari latihan (untuk kalender)
    await _db
        .collection('users')
        .doc(uid)
        .collection('workoutLogs')
        .doc(_dateStr(date))
        .set({
          'date': _dateStr(date),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Update gerakan (Update)
  Future<void> updateWorkoutEntry(
    String uid,
    DateTime date,
    String entryId,
    Map<String, dynamic> data,
  ) async {
    await _exercisesRef(uid, date).doc(entryId).update(data);
  }

  /// Hapus gerakan (Delete)
  Future<void> deleteWorkoutEntry(
    String uid,
    DateTime date,
    String entryId,
  ) async {
    await _exercisesRef(uid, date).doc(entryId).delete();
  }

  /// Toggle status selesai
  Future<void> toggleWorkoutComplete(
    String uid,
    DateTime date,
    String entryId,
    bool isCompleted,
  ) async {
    await _exercisesRef(
      uid,
      date,
    ).doc(entryId).update({'isCompleted': isCompleted});
    if (isCompleted) {
      await _updateStreak(uid, date);
    }
  }

  // ─── STREAK ─────────────────────────────────────────────────────────────────

  Future<void> _updateStreak(String uid, DateTime date) async {
    final completedDates = await _getCompletedWorkoutDates(uid);
    final today = _dateStr(date);
    if (!completedDates.contains(today)) completedDates.add(today);
    completedDates.sort();

    int streak = 0;
    DateTime check = DateTime.now();
    while (true) {
      final dateKey = _dateStr(check);
      if (completedDates.contains(dateKey)) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    await updateUserProfile(uid, {'streak': streak});
  }

  Future<List<String>> _getCompletedWorkoutDates(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('workoutLogs')
        .get();
    return snap.docs.map((d) => d.id).toList();
  }

  /// Ambil tanggal-tanggal yang ada workout log (untuk mini calendar)
  Future<List<String>> getWorkoutDatesThisMonth(String uid) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('workoutLogs')
        .where('date', isGreaterThanOrEqualTo: _dateStr(start))
        .where('date', isLessThanOrEqualTo: _dateStr(end))
        .get();
    return snap.docs.map((d) => d.id).toList();
  }

  /// Ambil semua tanggal workout (untuk streak dan kalender)
  Stream<List<String>> getWorkoutDatesStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('workoutLogs')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }

  // ─── PROGRAM AKTIF ──────────────────────────────────────────────────────────

  Future<void> setActiveProgram(
    String uid,
    Map<String, dynamic> programData,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('activeProgram')
        .doc('current')
        .set({
          ...programData,
          'startDate': FieldValue.serverTimestamp(),
          'dayCompleted': 0,
        });
  }

  Future<Map<String, dynamic>?> getActiveProgram(String uid) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('activeProgram')
        .doc('current')
        .get();
    if (doc.exists) return doc.data();
    return null;
  }

  Stream<Map<String, dynamic>?> getActiveProgramStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('activeProgram')
        .doc('current')
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  // INI ADALAH FUNGSI YANG BARU KITA UPDATE (HAPUS JADWAL SEKALIGUS)
  Future<void> cancelActiveProgram(String uid) async {
    try {
      // 1. Hapus status program aktif dari database
      await _db
          .collection('users')
          .doc(uid)
          .collection('activeProgram')
          .doc('current')
          .delete();

      // 2. Cari semua jadwal latihan yang sudah terlanjur dibuat di kalender
      final logsSnapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('workoutLogs')
          .get();

      // 3. Sapu bersih semuanya (Looping untuk menghapus tiap hari)
      for (var logDoc in logsSnapshot.docs) {
        // Bersihkan daftar gerakan (exercises) di hari tersebut
        final exercisesSnap = await logDoc.reference
            .collection('exercises')
            .get();
        for (var exDoc in exercisesSnap.docs) {
          await exDoc.reference.delete();
        }
        // Hapus tanggalnya dari kalender
        await logDoc.reference.delete();
      }
    } catch (e) {
      print("Gagal membatalkan program dan menghapus jadwal: $e");
    }
  }

  Future<void> updateProgramProgress(String uid, int dayCompleted) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('activeProgram')
        .doc('current')
        .update({'dayCompleted': dayCompleted});
  }

  // ─── CHAT HISTORY ───────────────────────────────────────────────────────────

  Future<void> saveChatMessage(String uid, ChatMessage message) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('chatHistory')
        .add(message.toMap());
  }

  Stream<List<ChatMessage>> getChatHistoryStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('chatHistory')
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ChatMessage.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  Future<List<ChatMessage>> getChatHistory(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('chatHistory')
        .orderBy('timestamp')
        .get();
    return snap.docs.map((d) => ChatMessage.fromMap(d.data(), d.id)).toList();
  }

  Future<void> clearChatHistory(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('chatHistory')
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }
}
