import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String _appVersion = '1.0.0';
  static const String _buildNumber = '1';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;

    return Scaffold(
      backgroundColor:
      isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile Card ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(isDark),
              child: Row(
                children: [
                  _AvatarWidget(
                    name: user?.name ?? 'U',
                    size: 52,
                    imagePath: user?.imagePath,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'User',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(user?.email ?? '',
                            style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 4),
                        if (user?.dateOfBirth != null)
                          Text(
                            'DOB: ${_formatDate(user!.dateOfBirth)}',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen()),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.lightTextSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Section: Preferences ──────────────────────────────────────
            _SectionHeader(label: 'Preferences', isDark: isDark),
            const SizedBox(height: 8),
            Container(
              decoration: _cardDecoration(isDark),
              child: Column(
                children: [
                  // Dark Mode
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        _IconBadge(
                          icon: Icons.dark_mode,
                          color: AppTheme.accentBlue,
                          bgColor: AppTheme.primaryBlue.withOpacity(0.15),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Dark Mode',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontSize: 15),
                          ),
                        ),
                        Switch(
                          value: provider.isDarkMode,
                          onChanged: (_) => provider.toggleTheme(),
                          activeColor: AppTheme.primaryBlue,
                        ),
                      ],
                    ),
                  ),

                  _Divider(isDark: isDark),

                  // Change Password
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    iconColor: Colors.orange,
                    bgColor: Colors.orange.withOpacity(0.12),
                    label: 'Change Password',
                    isDark: isDark,
                    theme: theme,
                    onTap: () => _showChangePasswordSheet(context),
                  ),

                  _Divider(isDark: isDark),

                  // Logout
                  InkWell(
                    onTap: () => _showLogoutDialog(context, provider),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          _IconBadge(
                            icon: Icons.logout,
                            color: Colors.redAccent,
                            bgColor: Colors.red.withOpacity(0.12),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Logout',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 15,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Section: About ────────────────────────────────────────────
            _SectionHeader(label: 'About', isDark: isDark),
            const SizedBox(height: 8),
            Container(
              decoration: _cardDecoration(isDark),
              child: Column(
                children: [
                  // Terms & Conditions
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    iconColor: const Color(0xFF9B59B6),
                    bgColor: const Color(0xFF9B59B6).withOpacity(0.12),
                    label: 'Terms & Conditions',
                    isDark: isDark,
                    theme: theme,
                    onTap: () => _showTermsSheet(context),
                  ),

                  _Divider(isDark: isDark),

                  // App Version
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        _IconBadge(
                          icon: Icons.info_outline_rounded,
                          color: const Color(0xFF3498DB),
                          bgColor:
                          const Color(0xFF3498DB).withOpacity(0.12),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'App Version',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontSize: 15),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'v$_appVersion ($_buildNumber)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Section: Account Management ───────────────────────────────
            _SectionHeader(label: 'Account Management', isDark: isDark),
            const SizedBox(height: 8),
            Container(
              decoration: _cardDecoration(isDark),
              child: InkWell(
                onTap: () => _showDeleteAccountSheet(context, provider),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      _IconBadge(
                        icon: Icons.delete_forever_outlined,
                        color: Colors.redAccent,
                        bgColor: Colors.red.withOpacity(0.12),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delete Account',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 15,
                                color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Permanently delete your account & data',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Footer ────────────────────────────────────────────────────
            Center(
              child: Text(
                'PKR Expense Tracker • v$_appVersion',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─── Card Decoration Helper ───────────────────────────────────────────────

  BoxDecoration _cardDecoration(bool isDark) => BoxDecoration(
    color: isDark ? AppTheme.darkSurface : Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ─── Terms & Conditions Sheet ─────────────────────────────────────────────

  void _showTermsSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                // Fixed header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkCardAlt
                                : const Color(0xFFDDE3EE),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9B59B6)
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              color: Color(0xFF9B59B6),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Terms & Conditions',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Last updated: April 2025',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                Divider(
                  color: isDark
                      ? AppTheme.darkCardAlt
                      : const Color(0xFFEEF0F5),
                  height: 1,
                ),

                // Scrollable content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    children: const [
                      _TermsSection(
                        title: '1. Acceptance of Terms',
                        body:
                        'By downloading, installing, or using the PKR Expense Tracker app, you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the application.',
                      ),
                      _TermsSection(
                        title: '2. Use of the Application',
                        body:
                        'PKR Expense Tracker is designed solely for personal financial tracking purposes. You agree to use this application only for lawful purposes and in a manner that does not infringe the rights of others. You are responsible for maintaining the confidentiality of your account credentials.',
                      ),
                      _TermsSection(
                        title: '3. Data & Privacy',
                        body:
                        'Your financial data is stored securely using Firebase Cloud Firestore. We do not sell, rent, or share your personal data with third parties. Your data is tied to your authenticated account and is only accessible by you.',
                      ),
                      _TermsSection(
                        title: '4. Account Responsibility',
                        body:
                        'You are solely responsible for all activity that occurs under your account. You must notify us immediately of any unauthorized use of your account. We reserve the right to suspend or terminate accounts that violate these terms.',
                      ),
                      _TermsSection(
                        title: '5. Accuracy of Information',
                        body:
                        'PKR Expense Tracker relies on data you enter manually. We are not responsible for any financial decisions made based on the information displayed in the app. Always verify important financial data independently.',
                      ),
                      _TermsSection(
                        title: '6. Intellectual Property',
                        body:
                        'All content, design, and functionality within this application are the exclusive property of the PKR Expense Tracker team. You may not copy, modify, distribute, or reverse-engineer any part of this application without prior written permission.',
                      ),
                      _TermsSection(
                        title: '7. Limitation of Liability',
                        body:
                        'To the fullest extent permitted by law, PKR Expense Tracker shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the application, including but not limited to data loss or financial loss.',
                      ),
                      _TermsSection(
                        title: '8. Changes to Terms',
                        body:
                        'We reserve the right to modify these Terms and Conditions at any time. Continued use of the application after changes are posted constitutes your acceptance of the revised terms.',
                      ),
                      _TermsSection(
                        title: '9. Governing Law',
                        body:
                        'These Terms and Conditions are governed by and construed in accordance with the laws of Pakistan. Any disputes arising from these terms shall be subject to the exclusive jurisdiction of the courts of Pakistan.',
                      ),
                      _TermsSection(
                        title: '10. Contact Us',
                        body:
                        'If you have any questions about these Terms and Conditions, please contact us at waqasahmed.rk@gmail.com. We are committed to addressing your concerns promptly and transparently.',
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─── Delete Account Sheet ─────────────────────────────────────────────────

  void _showDeleteAccountSheet(BuildContext context, AppProvider provider) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscure = true;
    bool isLoading = false;
    bool confirmed = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetHandle(isDark: isDark),
                      const SizedBox(height: 20),

                      // Icon + Title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                                Icons.delete_forever_outlined,
                                color: Colors.redAccent,
                                size: 24),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delete Account',
                                  style: theme.textTheme.titleLarge
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'This action is permanent and irreversible.',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Warning box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.red.withOpacity(0.25)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber,
                                    color: Colors.redAccent, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'What will be deleted:',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const _WarningItem(
                                'Your profile and personal information'),
                            const _WarningItem('All expense records'),
                            const _WarningItem('All income records'),
                            const _WarningItem('Your Firebase Auth account'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirmation checkbox
                      GestureDetector(
                        onTap: () =>
                            setSheetState(() => confirmed = !confirmed),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: confirmed
                                    ? Colors.redAccent
                                    : Colors.transparent,
                                border: Border.all(
                                  color: confirmed
                                      ? Colors.redAccent
                                      : (isDark
                                      ? AppTheme.darkTextSecondary
                                      : AppTheme.lightTextSecondary),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: confirmed
                                  ? const Icon(Icons.check,
                                  color: Colors.white, size: 14)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'I understand this action is permanent and cannot be undone.',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      Text('Confirm Password',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscure,
                        style: theme.textTheme.bodyLarge,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Password is required'
                            : null,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                            onPressed: () =>
                                setSheetState(() => obscure = !obscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Delete button — disabled until checkbox ticked
                      ElevatedButton(
                        onPressed: (isLoading || !confirmed)
                            ? null
                            : () async {
                          if (!formKey.currentState!.validate()) return;
                          setSheetState(() => isLoading = true);
                          try {
                            await provider.deleteAccount(
                                password: passwordController.text);
                            if (!ctx.mounted) return;
                            Navigator.of(ctx).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                                  (_) => false,
                            );
                          } on FirebaseAuthException catch (e) {
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    AuthService.getErrorMessage(e)),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10)),
                              ),
                            );
                          } catch (e) {
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10)),
                              ),
                            );
                          } finally {
                            if (ctx.mounted) {
                              setSheetState(() => isLoading = false);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                          Colors.redAccent.withOpacity(0.4),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                            : const Text(
                          'Permanently Delete Account',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Change Password Sheet ────────────────────────────────────────────────

  void _showChangePasswordSheet(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmNewPasswordController = TextEditingController();
    final sheetFormKey = GlobalKey<FormState>();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Form(
                  key: sheetFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetHandle(isDark: isDark),
                      const SizedBox(height: 20),
                      Text(
                        'Change Password',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 20),

                      Text('Current Password',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrent,
                        style: theme.textTheme.bodyLarge,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Current password is required'
                            : null,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrent
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                            onPressed: () => setSheetState(
                                    () => obscureCurrent = !obscureCurrent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text('New Password',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        style: theme.textTheme.bodyLarge,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'New password is required';
                          }
                          if (v.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          if (v == currentPasswordController.text) {
                            return 'New password must differ from current';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                            onPressed: () => setSheetState(
                                    () => obscureNew = !obscureNew),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text('Confirm New Password',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: confirmNewPasswordController,
                        obscureText: obscureConfirm,
                        style: theme.textTheme.bodyLarge,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please confirm new password';
                          }
                          if (v != newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                            onPressed: () => setSheetState(
                                    () => obscureConfirm = !obscureConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                          if (!sheetFormKey.currentState!.validate()) {
                            return;
                          }
                          setSheetState(() => isSaving = true);
                          try {
                            await context
                                .read<AppProvider>()
                                .changePassword(
                              currentPassword:
                              currentPasswordController.text,
                              newPassword:
                              newPasswordController.text,
                            );
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Password changed successfully!'),
                                backgroundColor: AppTheme.primaryBlue,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10)),
                              ),
                            );
                          } catch (e) {
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10)),
                              ),
                            );
                          } finally {
                            if (ctx.mounted) {
                              setSheetState(() => isSaving = false);
                            }
                          }
                        },
                        child: isSaving
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                            : const Text('Update Password'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Logout Dialog ────────────────────────────────────────────────────────

  Future<void> _showLogoutDialog(
      BuildContext context, AppProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout_rounded,
              color: Colors.redAccent, size: 28),
        ),
        title: const Text(
          'Logout',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to logout?\nYou will need to sign in again to continue.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(110, 42),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(110, 42),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.logout();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark
              ? AppTheme.darkTextSecondary
              : AppTheme.lightTextSecondary,
        ),
      ),
    );
  }
}

// ─── Icon Badge ───────────────────────────────────────────────────────────────

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _IconBadge(
      {required this.icon, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

// ─── Settings Tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.isDark,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _IconBadge(icon: icon, color: iconColor, bgColor: bgColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Divider ──────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: isDark ? AppTheme.darkCardAlt : const Color(0xFFEEF0F5),
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}

// ─── Sheet Handle ─────────────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  final bool isDark;
  const _SheetHandle({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardAlt : const Color(0xFFDDE3EE),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ─── Terms Section ────────────────────────────────────────────────────────────

class _TermsSection extends StatelessWidget {
  final String title;
  final String body;

  const _TermsSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13.5,
              height: 1.6,
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Warning Item ─────────────────────────────────────────────────────────────

class _WarningItem extends StatelessWidget {
  final String text;
  const _WarningItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.remove_circle_outline,
              color: Colors.redAccent, size: 14),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar Widget ────────────────────────────────────────────────────────────

class _AvatarWidget extends StatelessWidget {
  final String name;
  final double size;
  final String? imagePath;

  const _AvatarWidget({
    required this.name,
    required this.size,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && File(imagePath!).existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasImage
            ? null
            : const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF44A8A2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: hasImage
            ? DecorationImage(
          image: FileImage(File(imagePath!)),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: hasImage
          ? null
          : Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.35,
          ),
        ),
      ),
    );
  }
}