import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../models/income_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  UserModel? _currentUser;
  bool _isLoadingProfile = false;
  bool _isLoadingExpenses = false;
  bool _isLoadingIncomes = false;
  List<ExpenseModel> _expenses = [];
  List<IncomeModel> _incomes = [];

  StreamSubscription<List<ExpenseModel>>? _expensesSubscription;
  StreamSubscription<List<IncomeModel>>? _incomesSubscription;

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // ─── Getters ───────────────────────────────────────────────────────────────

  bool get isDarkMode => _isDarkMode;
  UserModel? get currentUser => _currentUser;
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isLoadingExpenses => _isLoadingExpenses;
  bool get isLoadingIncomes => _isLoadingIncomes;
  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);
  List<IncomeModel> get incomes => List.unmodifiable(_incomes);

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // ─── Sync Firebase user ────────────────────────────────────────────────────

  Future<void> syncFirebaseUser(User user) async {
    _isLoadingProfile = true;
    notifyListeners();

    try {
      final firestoreUser =
      await _firestoreService.fetchUserProfile(user.uid);
      _currentUser = firestoreUser ??
          UserModel(
            name: user.displayName ?? 'User',
            email: user.email ?? '',
            dateOfBirth: DateTime(1990, 1, 1),
          );
    } catch (_) {
      _currentUser = UserModel(
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        dateOfBirth: DateTime(1990, 1, 1),
      );
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }

    _subscribeToExpenses(user.uid);
    _subscribeToIncomes(user.uid);
  }

  // ─── Expenses Stream ───────────────────────────────────────────────────────

  void _subscribeToExpenses(String uid) {
    _isLoadingExpenses = true;
    notifyListeners();

    _expensesSubscription?.cancel();
    _expensesSubscription =
        _firestoreService.expensesStream(uid).listen(
              (expenses) {
            _expenses = expenses;
            _isLoadingExpenses = false;
            notifyListeners();
          },
          onError: (_) {
            _isLoadingExpenses = false;
            notifyListeners();
          },
        );
  }

  // ─── Incomes Stream ────────────────────────────────────────────────────────

  void _subscribeToIncomes(String uid) {
    _isLoadingIncomes = true;
    notifyListeners();

    _incomesSubscription?.cancel();
    _incomesSubscription =
        _firestoreService.incomesStream(uid).listen(
              (incomes) {
            _incomes = incomes;
            _isLoadingIncomes = false;
            notifyListeners();
          },
          onError: (_) {
            _isLoadingIncomes = false;
            notifyListeners();
          },
        );
  }

  // ─── Login ─────────────────────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    final credential = await _authService.login(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      await syncFirebaseUser(credential.user!);
    }
  }

  // ─── Sign Up ───────────────────────────────────────────────────────────────

  Future<void> signUp(String name, String email, String password) async {
    final credential = await _authService.signUp(
      name: name,
      email: email,
      password: password,
    );
    if (credential.user != null) {
      await _firestoreService.createUserOnSignUp(
        uid: credential.user!.uid,
        name: name,
        email: email,
      );
      await syncFirebaseUser(credential.user!);
    }
  }
// ─── Deactivate Account ────────────────────────────────────────────────────

  Future<void> deactivateAccount({required String password}) async {
    await _authService.deactivateAccount(password: password);

    // Clear all local state
    await _expensesSubscription?.cancel();
    await _incomesSubscription?.cancel();
    _expensesSubscription = null;
    _incomesSubscription = null;
    _currentUser = null;
    _expenses = [];
    _incomes = [];
    notifyListeners();
  }

// ─── Delete Account Permanently ───────────────────────────────────────────

  Future<void> deleteAccount({required String password}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw 'No authenticated user found.';

    // Delete all Firestore data first
    await _firestoreService.deleteAllUserData(uid);

    // Delete Firebase Auth account
    await _authService.deleteAccount(password: password);

    // Cancel streams and clear local state
    await _expensesSubscription?.cancel();
    await _incomesSubscription?.cancel();
    _expensesSubscription = null;
    _incomesSubscription = null;
    _currentUser = null;
    _expenses = [];
    _incomes = [];
    notifyListeners();
  }
  // ─── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _expensesSubscription?.cancel();
    await _incomesSubscription?.cancel();
    _expensesSubscription = null;
    _incomesSubscription = null;

    await _authService.logout();
    _currentUser = null;
    _expenses = [];
    _incomes = [];
    notifyListeners();
  }

  // ─── Update Profile ────────────────────────────────────────────────────────

  Future<void> updateProfile({
    required String name,
    required String email,
    DateTime? dob,
    String? imagePath,
    bool clearImage = false,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Optimistic local update
    _currentUser = _currentUser?.copyWith(
      name: name,
      email: email,
      dateOfBirth: dob,
      imagePath: imagePath ?? _currentUser?.imagePath,
      clearImage: clearImage,
    );
    notifyListeners();

    await _firestoreService.saveUserProfile(
      uid: uid,
      name: name,
      email: email,
      dateOfBirth: dob,
      imagePath:
      clearImage ? null : (imagePath ?? _currentUser?.imagePath),
    );

    await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
  }

  // ─── Add Expense ───────────────────────────────────────────────────────────

  Future<void> addExpense(ExpenseModel expense) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Optimistic update
    _expenses = [expense, ..._expenses];
    notifyListeners();

    try {
      await _firestoreService.addExpense(uid: uid, expense: expense);
    } catch (_) {
      // Revert on failure
      _expenses = _expenses.where((e) => e.id != expense.id).toList();
      notifyListeners();
      rethrow;
    }
  }

  // ─── Update Expense ────────────────────────────────────────────────────────

  Future<void> updateExpense(ExpenseModel updated) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Store original for revert
    final original = _expenses.firstWhere((e) => e.id == updated.id);

    // Optimistic local update
    _expenses = _expenses
        .map((e) => e.id == updated.id ? updated : e)
        .toList();
    notifyListeners();

    try {
      await _firestoreService.updateExpense(uid: uid, expense: updated);
    } catch (_) {
      // Revert on failure
      _expenses = _expenses
          .map((e) => e.id == original.id ? original : e)
          .toList();
      notifyListeners();
      rethrow;
    }
  }

  // ─── Delete Expense ────────────────────────────────────────────────────────

  Future<void> deleteExpense(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Store for revert
    final removed = _expenses.firstWhere((e) => e.id == id);

    // Optimistic update
    _expenses = _expenses.where((e) => e.id != id).toList();
    notifyListeners();

    try {
      await _firestoreService.deleteExpense(uid: uid, expenseId: id);
    } catch (_) {
      // Revert on failure
      _expenses = [removed, ..._expenses];
      notifyListeners();
      rethrow;
    }
  }

  // ─── Add Income ────────────────────────────────────────────────────────────

  Future<void> addIncome(IncomeModel income) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Optimistic update
    _incomes = [income, ..._incomes];
    notifyListeners();

    try {
      await _firestoreService.addIncome(uid: uid, income: income);
    } catch (_) {
      // Revert on failure
      _incomes = _incomes.where((i) => i.id != income.id).toList();
      notifyListeners();
      rethrow;
    }
  }

  // ─── Update Income ─────────────────────────────────────────────────────────

  Future<void> updateIncome(IncomeModel updated) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Store original for revert
    final original = _incomes.firstWhere((i) => i.id == updated.id);

    // Optimistic local update
    _incomes = _incomes
        .map((i) => i.id == updated.id ? updated : i)
        .toList();
    notifyListeners();

    try {
      await _firestoreService.updateIncome(uid: uid, income: updated);
    } catch (_) {
      // Revert on failure
      _incomes = _incomes
          .map((i) => i.id == original.id ? original : i)
          .toList();
      notifyListeners();
      rethrow;
    }
  }

  // ─── Delete Income ─────────────────────────────────────────────────────────

  Future<void> deleteIncome(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Store for revert
    final removed = _incomes.firstWhere((i) => i.id == id);

    // Optimistic update
    _incomes = _incomes.where((i) => i.id != id).toList();
    notifyListeners();

    try {
      await _firestoreService.deleteIncome(uid: uid, incomeId: id);
    } catch (_) {
      // Revert on failure
      _incomes = [removed, ..._incomes];
      notifyListeners();
      rethrow;
    }
  }

  // ─── Change Password ───────────────────────────────────────────────────────

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      throw 'No authenticated user found.';
    }
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    try {
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthService.getErrorMessage(e);
    }
  }

  // ─── Computed Getters ──────────────────────────────────────────────────────

  double get totalExpenses =>
      _expenses.fold(0, (sum, e) => sum + e.amount);

  double get totalIncome =>
      _incomes.fold(0, (sum, i) => sum + i.amount);

  double get netBalance => totalIncome - totalExpenses;

  int get transactionCount => _expenses.length;

  int get incomeCount => _incomes.length;

  Map<String, double> get expensesByCategory {
    final map = <String, double>{};
    for (final e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  Map<String, double> get incomesBySource {
    final map = <String, double>{};
    for (final i in _incomes) {
      map[i.source] = (map[i.source] ?? 0) + i.amount;
    }
    return map;
  }

  // ─── Filtered Expenses ─────────────────────────────────────────────────────

  List<ExpenseModel> getFilteredExpenses(String filter) {
    final now = DateTime.now();
    switch (filter) {
      case 'Daily':
        return _expenses
            .where((e) =>
        e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
            .toList();
      case 'Weekly':
        final weekAgo = now.subtract(const Duration(days: 7));
        return _expenses
            .where((e) => e.date.isAfter(weekAgo))
            .toList();
      case 'Monthly':
        return _expenses
            .where((e) =>
        e.date.year == now.year &&
            e.date.month == now.month)
            .toList();
      case 'Yearly':
        return _expenses
            .where((e) => e.date.year == now.year)
            .toList();
      default:
        return List.from(_expenses);
    }
  }

  // ─── Filtered Incomes ──────────────────────────────────────────────────────

  List<IncomeModel> getFilteredIncomes(String filter) {
    final now = DateTime.now();
    switch (filter) {
      case 'Daily':
        return _incomes
            .where((i) =>
        i.date.year == now.year &&
            i.date.month == now.month &&
            i.date.day == now.day)
            .toList();
      case 'Weekly':
        final weekAgo = now.subtract(const Duration(days: 7));
        return _incomes
            .where((i) => i.date.isAfter(weekAgo))
            .toList();
      case 'Monthly':
        return _incomes
            .where((i) =>
        i.date.year == now.year &&
            i.date.month == now.month)
            .toList();
      case 'Yearly':
        return _incomes
            .where((i) => i.date.year == now.year)
            .toList();
      default:
        return List.from(_incomes);
    }
  }
}