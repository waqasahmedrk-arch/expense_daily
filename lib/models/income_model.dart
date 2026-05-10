class IncomeModel {
  final String id;
  final String title;
  final double amount;
  final String source;
  final DateTime date;

  IncomeModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.source,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'source': source,
    'date': date.toIso8601String(),
  };

  factory IncomeModel.fromMap(Map<String, dynamic> map) => IncomeModel(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    amount: (map['amount'] as num).toDouble(),
    source: map['source'] ?? 'Other',
    date: DateTime.parse(map['date']),
  );
}

const List<String> incomeSources = [
  'Salary',
  'Freelance',
  'Business',
  'Investment',
  'Gift',
  'Other',
];

const Map<String, int> sourceIcons = {
  'Salary':     0xe8a1, // work
  'Freelance':  0xe332, // laptop
  'Business':   0xe0af, // store
  'Investment': 0xe6de, // trending_up
  'Gift':       0xe88e, // card_giftcard
  'Other':      0xe8b8, // attach_money
};