import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatelessWidget {
  TransactionHistoryScreen({super.key}); // Removed const here
  final List<Map<String, dynamic>> transactions = [
    {'date': '2024-12-01', 'type': 'Buy', 'amount': 100.0, 'currency': 'USD'},
    {'date': '2024-12-02', 'type': 'Sell', 'amount': 200.0, 'currency': 'EUR'},
    // Sample data; replace with API response
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaction History')),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return ListTile(
            title: Text(
                '${transaction['type']} ${transaction['amount']} ${transaction['currency']}'),
            subtitle: Text(transaction['date']),
          );
        },
      ),
    );
  }
}
