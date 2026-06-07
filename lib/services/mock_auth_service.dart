class MockAuthService {
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  // Menyimpan data user (email sebagai key) -> {name, password}
  // Diberi satu data bawaan agar gampang ditest
  final Map<String, Map<String, String>> _users = {
    'test@gerak.com': {
      'name': 'Tester Gerak',
      'password': 'password123'
    }
  };

  /// Cek apakah email sudah terdaftar
  bool isEmailRegistered(String email) {
    return _users.containsKey(email);
  }

  /// Mendaftarkan user baru. Return false jika email sudah ada.
  bool register(String name, String email, String password) {
    if (isEmailRegistered(email)) return false;
    _users[email] = {'name': name, 'password': password};
    return true;
  }

  /// Login. Return 'SUCCESS', 'NOT_FOUND', atau 'WRONG_PASSWORD'.
  String login(String email, String password) {
    if (!isEmailRegistered(email)) return 'NOT_FOUND';
    if (_users[email]!['password'] == password) return 'SUCCESS';
    return 'WRONG_PASSWORD';
  }

  /// Ambil nama user berdasarkan email
  String getName(String email) {
    return _users[email]?['name'] ?? 'Sobat Sehat';
  }
}
