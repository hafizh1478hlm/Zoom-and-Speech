import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Mengurus login dan logout dengan akun Google.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn();

  /// Pengguna yang sedang login (null jika tamu).
  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  /// Mengembalikan User jika berhasil, atau null jika pengguna
  /// menutup pemilih akun Google (dibatalkan).
  Future<User?> signInWithGoogle() async {
    final account = await _google.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }
}