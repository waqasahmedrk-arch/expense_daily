import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'wrapper_screen.dart';
import '../widgets/app_logo.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _submitted = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Validators ───────────────────────────────────────────────────────────

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  // ─── Sign Up ──────────────────────────────────────────────────────────────

  void _signUp() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await context.read<AppProvider>().signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // WrapperScreen detects unverified email → shows VerifyEmailScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WrapperScreen()),
            (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthService.getErrorMessage(e)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Field Builder ────────────────────────────────────────────────────────

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    bool obscure = false,
    bool? obscureValue,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure ? (obscureValue ?? true) : false,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyLarge,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: obscure
                ? IconButton(
              icon: Icon(
                (obscureValue ?? true)
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary,
              ),
              onPressed: onToggle,
            )
                : null,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        color: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color:
                      isDark ? AppTheme.darkSurface : Colors.white,
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
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Center(child: AppLogo()),
                          const SizedBox(height: 20),
                          Center(
                            child: Text('Create Account',
                                style: theme.textTheme.headlineMedium),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: Text('Start tracking your expenses',
                                style: theme.textTheme.bodyMedium),
                          ),
                          const SizedBox(height: 28),

                          _buildField(
                            controller: _nameController,
                            label: 'Full Name',
                            hint: 'John Doe',
                            validator: _validateName,
                            theme: theme,
                          ),
                          _buildField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'your@email.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            theme: theme,
                          ),
                          _buildField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '••••••••',
                            obscure: true,
                            obscureValue: _obscurePassword,
                            onToggle: () => setState(() =>
                            _obscurePassword = !_obscurePassword),
                            validator: _validatePassword,
                            theme: theme,
                          ),
                          _buildField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            hint: '••••••••',
                            obscure: true,
                            obscureValue: _obscureConfirm,
                            onToggle: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                            validator: _validateConfirmPassword,
                            theme: theme,
                          ),
                          const SizedBox(height: 10),

                          // ── Sign Up Button ───────────────────────────────
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2),
                            )
                                : const Text('Sign Up'),
                          ),
                          const SizedBox(height: 20),

                          // ── Login Link ───────────────────────────────────
                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: theme.textTheme.bodyMedium,
                                children: [
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context)
                                          .pushReplacement(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                            const LoginScreen()),
                                      ),
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                          color: AppTheme.accentBlue,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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