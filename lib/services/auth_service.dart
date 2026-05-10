import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Sign Up ───────────────────────────────────────────────────────────────

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Set display name
    await credential.user?.updateDisplayName(name);

    // Send verification email
    await credential.user?.sendEmailVerification();

    return credential;
  }

  // ─── Login ─────────────────────────────────────────────────────────────────

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ─── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ─── Resend Verification Email ─────────────────────────────────────────────

  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // ─── Reload User (check verification status) ──────────────────────────────

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }
// ─── Deactivate Account (disable without deleting) ────────────────────────

  Future<void> deactivateAccount({required String password}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
          code: 'no-user', message: 'No authenticated user found.');
    }

    // Re-authenticate before sensitive operation
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);

    // Sign out — account still exists but user loses access
    await _auth.signOut();
  }

// ─── Delete Account Permanently ───────────────────────────────────────────

  Future<void> deleteAccount({required String password}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
          code: 'no-user', message: 'No authenticated user found.');
    }

    // Re-authenticate before deletion
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);

    // Delete Firebase Auth account
    await user.delete();
  }
  // ─── Password Reset ────────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─── Firebase error messages → readable strings ───────────────────────────

  static String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}