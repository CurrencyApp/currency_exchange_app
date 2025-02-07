class Transaction {
  final String id;
  final String userId;
  final String currency;
  final double amount;
  final String type; // "buy" or "sell"
  final DateTime date;

  Transaction({
    required this.id,
    required this.userId,
    required this.currency,
    required this.amount,
    required this.type,
    required this.date,
  });

  // Convert JSON to Transaction object
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      currency: json['currency'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  // Convert Transaction object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'currency': currency,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
    };
  }
}
