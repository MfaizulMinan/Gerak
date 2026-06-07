import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Mendapatkan user saat ini
  User? get currentUser => _auth.currentUser;

  // Stream status auth
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login dengan Email & Password
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        throw 'Akun dengan email ini tidak ditemukan.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw 'Password yang Anda masukkan salah.';
      } else {
        throw 'Terjadi kesalahan: ${e.message}';
      }
    } catch (e) {
      throw 'Terjadi kesalahan sistem.';
    }
  }

  // Register dengan Email & Password
  Future<UserCredential> registerWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      // Update display name
      await userCredential.user?.updateDisplayName(name);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'Password terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        throw 'Email ini sudah terdaftar. Silakan Login.';
      } else {
        throw 'Terjadi kesalahan: ${e.message}';
      }
    } catch (e) {
      throw 'Terjadi kesalahan sistem.';
    }
  }

  // Login dengan Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Memulai proses login Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Jika pengguna membatalkan login
      if (googleUser == null) {
        throw 'Proses login dibatalkan.';
      }

      // Mendapatkan otentikasi dari request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Membuat credential baru
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login ke Firebase menggunakan Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw 'Gagal login dengan Google: $e';
    }
  }

  // Sign out (SUDAH DIPERBAIKI)
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Abaikan kalau error (misalnya user login pakai Email, bukan Google)
    }
    await _auth.signOut();
  }
}
