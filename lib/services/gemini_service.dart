import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_message.dart';

class GeminiService {
  static const String _apiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  bool get isConfigured => _apiKey.isNotEmpty && _apiKey != 'YOUR_API_KEY_HERE';

  Future<String> sendMessage({
    required String userMessage,
    required List<ChatMessage> history,
    String? activeProgramContext,
    String? userProfileContext,
  }) async {
    if (!isConfigured) {
      return "Error: API Key belum dikonfigurasi.";
    }

    try {
      // Mengatur kepribadian dan MENGGUNAKAN MODEL GENERASI KE-3 (TERBARU!)
      final model = GenerativeModel(
        model: 'gemini-3.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(
          'Kamu adalah Coach AI, asisten virtual dari aplikasi fitness GERAK. '
          'Tugasmu adalah menjawab pertanyaan seputar kebugaran, olahraga, dan nutrisi dengan ramah, semangat, dan menggunakan bahasa Indonesia yang santai tapi sopan. '
          'Jangan menjawab pertanyaan di luar konteks kesehatan/fitness (misalnya politik, coding, dll). '
          'Gunakan emoji secukupnya agar terlihat ramah. '
          'Berikut adalah data pengguna yang sedang berbicara denganmu:\n'
          'Profil: ${userProfileContext ?? "Belum ada data profil"}\n'
          'Program Aktif: ${activeProgramContext ?? "Belum ada program aktif"}',
        ),
      );

      // Menerjemahkan riwayat chat aplikasi ke format yang dimengerti Gemini
      final chatHistory = history.map((msg) {
        return Content(msg.role == 'user' ? 'user' : 'model', [
          TextPart(msg.content),
        ]);
      }).toList();

      // Memulai obrolan dan mengirim pesan
      final chat = model.startChat(history: chatHistory);
      final response = await chat.sendMessage(Content.text(userMessage));

      return response.text ??
          "Maaf, saya sedang kehabisan kata-kata. Coba tanya lagi!";
    } catch (e) {
      // Menangkap error jika terjadi masalah lagi
      print('=== GEMINI ERROR: $e ===');
      return "Waduh, koneksi ke server pusat terputus. 📡\n\n(Pesan Sistem: $e)";
    }
  }
}
