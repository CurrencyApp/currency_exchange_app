class ExchangeRate {
  final String currency;
  final double rate;

  ExchangeRate({
    required this.currency,
    required this.rate,
  });

  // Convert JSON to ExchangeRate object
  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      currency: json['currency'] as String,
      rate: (json['rate'] as num).toDouble(),
    );
  }

  // Convert ExchangeRate object to JSON
  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'rate': rate,
    };
  }
}
