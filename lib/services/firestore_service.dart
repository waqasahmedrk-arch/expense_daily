import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import '../models/income_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Collection references ─────────────────────────────────────────────────

  DocumentReference _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference _expensesCol(String uid) =>
      _userDoc(uid).collection('expenses');

  CollectionReference _incomesCol(String uid) =>
      _userDoc(uid).collection('incomes');

  // ─── User Profile ──────────────────────────────────────────────────────────

  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    DateTime? dateOfBirth,
    String? imagePath,
  }) async {
    await _userDoc(uid).set(
      {
        'name': name,
        'email': email,
        'dateOfBirth': dateOfBirth != null
            ? Timestamp.fromDate(dateOfBirth)
            : null,
        'imagePath': imagePath,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),                          // <-- safe merge
    );
  }

  Future<UserModel?> fetchUserProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      imagePath: data['imagePath'],
      dateOfBirth: data['dateOfBirth'] != null
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : DateTime(1990, 1, 1),
    );
  }

  Future<void> createUserOnSignUp({
    required String uid,
    required String name,
    required String email,
  }) async {
    final doc = await _userDoc(uid).get();
    if (doc.exists) return;                             // <-- don't overwrite
    await _userDoc(uid).set({
      'name': name,
      'email': email,
      'dateOfBirth': null,
      'imagePath': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Expenses — CRUD ───────────────────────────────────────────────────────

  Future<void> addExpense({
    required String uid,
    required ExpenseModel expense,
  }) async {
    await _expensesCol(uid)
        .doc(expense.id)
        .set(expense.toMap());
  }

  Future<void> updateExpense({
    required String uid,
    required ExpenseModel expense,
  }) async {
    await _expensesCol(uid)
        .doc(expense.id)
        .update({
      ...expense.toMap(),
      'updatedAt': FieldValue.serverTimestamp(), // <-- track update time
    });
  }

  Future<void> deleteExpense({
    required String uid,
    required String expenseId,
  }) async {
    await _expensesCol(uid).doc(expenseId).delete();
  }

  Future<List<ExpenseModel>> fetchExpenses(String uid) async {
    final snapshot = await _expensesCol(uid)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) =>
        ExpenseModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<ExpenseModel>> expensesStream(String uid) {
    return _expensesCol(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ExpenseModel.fromMap(
        doc.data() as Map<String, dynamic>))
        .toList());
  }
// ─── Delete All User Data ──────────────────────────────────────────────────

  Future<void> deleteAllUserData(String uid) async {
    // Delete all expenses
    final expenses = await _expensesCol(uid).get();
    for (final doc in expenses.docs) {
      await doc.reference.delete();
    }

    // Delete all incomes
    final incomes = await _incomesCol(uid).get();
    for (final doc in incomes.docs) {
      await doc.reference.delete();
    }

    // Delete user document
    await _userDoc(uid).delete();
  }
  // ─── Incomes — CRUD ────────────────────────────────────────────────────────

  Future<void> addIncome({
    required String uid,
    required IncomeModel income,
  }) async {
    await _incomesCol(uid)
        .doc(income.id)
        .set(income.toMap());
  }

  Future<void> updateIncome({
    required String uid,
    required IncomeModel income,
  }) async {
    await _incomesCol(uid)
        .doc(income.id)
        .update({
      ...income.toMap(),
      'updatedAt': FieldValue.serverTimestamp(), // <-- track update time
    });
  }

  Future<void> deleteIncome({
    required String uid,
    required String incomeId,
  }) async {
    await _incomesCol(uid).doc(incomeId).delete();
  }

  Future<List<IncomeModel>> fetchIncomes(String uid) async {
    final snapshot = await _incomesCol(uid)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) =>
        IncomeModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<IncomeModel>> incomesStream(String uid) {
    return _incomesCol(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => IncomeModel.fromMap(
        doc.data() as Map<String, dynamic>))
        .toList());
  }
}