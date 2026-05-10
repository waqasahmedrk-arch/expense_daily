import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';

class WrapperScreen extends StatelessWidget {
  const WrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // ─── Still connecting ───────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ─── Not logged in ──────────────────────────────────────────────────
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        final user = snapshot.data!;

        // ─── Logged in but not verified ─────────────────────────────────────
        if (!user.emailVerified) {
          return const VerifyEmailScreen();
        }

        // ─── Verified — sync user into provider then go home ────────────────
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<AppProvider>().syncFirebaseUser(user);
        });

        return const HomeScreen();
      },
    );
  }
}