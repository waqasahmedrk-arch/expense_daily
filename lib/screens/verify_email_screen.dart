import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  Timer? _pollTimer;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  bool _isVerified = false;             // <-- tracks verified state for UI switch

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    // Poll every 4 seconds to check if user clicked the link
    _pollTimer =
        Timer.periodic(const Duration(seconds: 4), (_) => _checkVerified());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  // ─── Check Verification ───────────────────────────────────────────────────

  Future<void> _checkVerified() async {
    await _authService.reloadUser();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified && mounted) {
      _pollTimer?.cancel();
      context.read<AppProvider>().syncFirebaseUser(user);

      // Switch UI to verified state with fresh animation
      setState(() => _isVerified = true);
      _animController.reset();
      _animController.forward();
    }
  }

  // ─── Resend Email ─────────────────────────────────────────────────────────

  Future<void> _resendEmail() async {
    if (_resendCooldown > 0) return;
    setState(() => _isResending = true);
    try {
      await _authService.resendVerificationEmail();
      setState(() => _resendCooldown = 30);
      _cooldownTimer =
          Timer.periodic(const Duration(seconds: 1), (t) {
            if (!mounted) { t.cancel(); return; }
            setState(() => _resendCooldown--);
            if (_resendCooldown <= 0) t.cancel();
          });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Verification email sent!'),
          backgroundColor: AppTheme.primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthService.getErrorMessage(e)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor:
      isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(isDark ? 0.4 : 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  // Switch between pending and verified UI
                  child: _isVerified
                      ? _VerifiedContent(theme: theme)
                      : _PendingContent(
                    theme: theme,
                    isDark: isDark,
                    email: email,
                    isResending: _isResending,
                    resendCooldown: _resendCooldown,
                    onResend: _resendEmail,
                    onBack: _logout,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pending Verification UI ──────────────────────────────────────────────────

class _PendingContent extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  final String email;
  final bool isResending;
  final int resendCooldown;
  final VoidCallback onResend;
  final VoidCallback onBack;

  const _PendingContent({
    required this.theme,
    required this.isDark,
    required this.email,
    required this.isResending,
    required this.resendCooldown,
    required this.onResend,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_unread_outlined,
            color: AppTheme.primaryBlue,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),

        Text('Verify Your Email', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 12),

        // Main message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  color: AppTheme.primaryBlue, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      const TextSpan(
                        text:
                        'Go to your mail inbox and verify your account. '
                            'We sent a verification link to\n',
                      ),
                      TextSpan(
                        text: email,
                        style: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'This page will update automatically once you click the link.',
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),

        // Resend button
        ElevatedButton.icon(
          onPressed: (isResending || resendCooldown > 0) ? null : onResend,
          icon: isResending
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.white),
          )
              : const Icon(Icons.send_outlined, size: 18),
          label: Text(
            resendCooldown > 0
                ? 'Resend in ${resendCooldown}s'
                : 'Resend Email',
          ),
        ),
        const SizedBox(height: 12),

        TextButton(
          onPressed: onBack,
          child: const Text(
            'Back to Login',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}

// ─── Verified Success UI ──────────────────────────────────────────────────────

class _VerifiedContent extends StatelessWidget {
  final ThemeData theme;

  const _VerifiedContent({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified_rounded,
            color: Colors.green,
            size: 52,
          ),
        ),
        const SizedBox(height: 24),

        Text('Email Verified!', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 12),

        // Success message box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.green.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your email has been verified. You may now login to your account.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Go to Login button
        ElevatedButton.icon(
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.login_rounded, size: 18),
          label: const Text('Login to Your Account'),
        ),
      ],
    );
  }
}