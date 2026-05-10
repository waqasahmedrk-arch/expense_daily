import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel {
  final String name;
  final String email;
  final String? imagePath;
  final DateTime dateOfBirth;

  const UserModel({
    required this.name,
    required this.email,
    this.imagePath,
    required this.dateOfBirth,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? imagePath,
    DateTime? dateOfBirth,
    bool clearImage = false,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final Color color;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.color,
  });

  // ─── Firestore serialization ───────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),    // <-- store as Firestore Timestamp
      'createdAt': FieldValue.serverTimestamp(),
    };
    // Note: color is NOT stored — it's derived from category via categoryColors
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] ?? 'Other',
      date: (map['date'] as Timestamp).toDate(),
      // Derive color from category — no need to store it
      color: categoryColors[map['category']] ?? const Color(0xFF9B59B6),
    );
  }
}

const List<String> expenseCategories = [
  'Food',
  'Transport',
  'Shopping',
  'Health',
  'Entertainment',
  'Bills',
  'Other',
];

const Map<String, Color> categoryColors = {
  'Food': Color(0xFFFF6B6B),
  'Transport': Color(0xFF4ECDC4),
  'Shopping': Color(0xFFFFBE0B),
  'Health': Color(0xFF06D6A0),
  'Entertainment': Color(0xFF9B5DE5),
  'Bills': Color(0xFF4C6EF5),
  'Other': Color(0xFFFF9F1C),
};