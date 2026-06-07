import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/chat_message.dart';
import '../../services/firestore_service.dart';
import '../../services/gemini_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _geminiService = GeminiService();
  final _firestoreService = FirestoreService();

  final List<ChatMessage> _localMessages = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _uid;
  String? _activeProgramContext;
  String? _userProfileContext;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _initChat();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    if (_uid == null) return;

    // Muat riwayat chat dari Firestore
    final history = await _firestoreService.getChatHistory(_uid!);
    // Muat profil untuk konteks
    final profile = await _firestoreService.getUserProfile(_uid!);
    final activeProgram = await _firestoreService.getActiveProgram(_uid!);

    if (profile != null) {
      final name = profile['name'] ?? 'Pengguna';
      final weight = profile['weight'] ?? 0;
      final height = profile['height'] ?? 0;
      final streak = profile['streak'] ?? 0;
      _userProfileContext = 'Nama: $name | Berat: ${weight}kg | Tinggi: ${height}cm | Streak: $streak hari';
    }

    if (activeProgram != null) {
      final programTitle = activeProgram['title'] ?? '';
      final dayCompleted = activeProgram['dayCompleted'] ?? 0;
      final totalDays = activeProgram['totalDays'] ?? 30;
      _activeProgramContext = 'Program aktif: $programTitle | Hari ke-$dayCompleted dari $totalDays hari';
    }

    if (mounted) {
      setState(() {
        if (history.isEmpty) {
          // Pesan sambutan dari AI
          _localMessages.add(ChatMessage(
            id: 'welcome',
            role: 'assistant',
            content: '👋 Halo! Saya Coach AI dari GERAK.\n\nSaya siap membantu kamu dalam perjalanan fitness! Kamu bisa tanya tentang:\n🏋️ Tips latihan & gerakan\n🥗 Panduan nutrisi & makanan\n💪 Program fitness\n📊 Progress & motivasi\n\nAda yang bisa saya bantu hari ini?',
            timestamp: DateTime.now(),
          ));
        } else {
          _localMessages.addAll(history);
        }
        _isInitialized = true;
      });
    }
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _localMessages.add(userMsg);
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    // Simpan ke Firestore
    if (_uid != null) {
      await _firestoreService.saveChatMessage(_uid!, userMsg);
    }

    // Ambil hanya 10 pesan terakhir sebagai konteks (untuk efisiensi token)
    final contextHistory = _localMessages.length > 11
        ? _localMessages.sublist(_localMessages.length - 11, _localMessages.length - 1)
        : _localMessages.sublist(0, _localMessages.length - 1);

    // Kirim ke Gemini
    final response = await _geminiService.sendMessage(
      userMessage: text,
      history: contextHistory.where((m) => m.id != 'welcome').toList(),
      activeProgramContext: _activeProgramContext,
      userProfileContext: _userProfileContext,
    );

    final aiMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'assistant',
      content: response,
      timestamp: DateTime.now(),
    );

    if (mounted) {
      setState(() {
        _localMessages.add(aiMsg);
        _isLoading = false;
      });
    }

    // Simpan respons AI ke Firestore
    if (_uid != null) {
      await _firestoreService.saveChatMessage(_uid!, aiMsg);
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Riwayat Chat?'),
        content: const Text('Semua percakapan sebelumnya akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && _uid != null) {
      await _firestoreService.clearChatHistory(_uid!);
      if (mounted) {
        setState(() {
          _localMessages.clear();
          _localMessages.add(ChatMessage(
            id: 'welcome',
            role: 'assistant',
            content: '🔄 Riwayat chat telah dibersihkan. Mari mulai percakapan baru!\n\nAda yang bisa saya bantu? 💪',
            timestamp: DateTime.now(),
          ));
        });
      }
    }
  }

  // Quick prompt chips
  final List<String> _quickPrompts = [
    '💪 Tips Push Up yang benar',
    '🥗 Menu makan sehat untuk bulking',
    '🔥 Latihan HIIT 15 menit',
    '😴 Pentingnya istirahat otot',
    '📊 Cara hitung kebutuhan kalori',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFF4CAF50),
              radius: 16,
              child: Text('AI', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Coach AI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Gemini Powered', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearHistory,
            tooltip: 'Hapus riwayat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status API key warning
          if (!_geminiService.isConfigured)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.orange.shade50,
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'API Key belum dikonfigurasi. Tambahkan di gemini_service.dart',
                      style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: !_isInitialized
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _localMessages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (ctx, index) {
                      if (index == _localMessages.length) {
                        return _TypingIndicator();
                      }
                      return _ChatBubble(message: _localMessages[index]);
                    },
                  ),
          ),

          // Quick prompts (tampil saat awal / chat sepi)
          if (_localMessages.length <= 1)
            Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: 4),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickPrompts.length,
                separatorBuilder: (ctx2, i2) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) => GestureDetector(
                  onTap: () {
                    _textController.text = _quickPrompts[i].substring(2).trim();
                    _sendMessage();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(_quickPrompts[i], style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),

          // Input area
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -3))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Tanya seputar fitness & nutrisi...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: FloatingActionButton.small(
                    onPressed: _isLoading ? null : _sendMessage,
                    backgroundColor: _isLoading ? Colors.grey.shade300 : Theme.of(context).primaryColor,
                    elevation: 0,
                    child: _isLoading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chat bubble ──────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF4CAF50),
              child: const Text('AI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Theme.of(context).primaryColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : const Color(0xFF1A1D20),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF4CAF50),
            child: Text('AI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (ctx2, child2) => Row(
                children: List.generate(3, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withValues(alpha: (i == 1 ? _animation.value : 1 - _animation.value + 0.4).clamp(0.2, 1.0)),
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
