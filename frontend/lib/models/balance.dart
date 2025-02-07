class UserBalance {
  final String userId;
  final double balance;
  final String currency;

  UserBalance({
    required this.userId,
    required this.balance,
    required this.currency,
  });

  // Convert JSON to UserBalance object
  factory UserBalance.fromJson(Map<String, dynamic> json) {
    return UserBalance(
      userId: json['userId'] as String,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }

  // Convert UserBalance object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'balance': balance,
      'currency': currency,
    };
  }
}
