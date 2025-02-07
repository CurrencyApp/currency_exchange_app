import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart'; // Import provider
import '../providers/user_provider.dart'; // Import UserProvider

class FundAccountScreen extends StatefulWidget {
  FundAccountScreen({Key? key}) : super(key: key);

  @override
  _FundAccountScreenState createState() => _FundAccountScreenState();
}

class _FundAccountScreenState extends State<FundAccountScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedCurrency;
  double? userBalance;
  String? userCurrency;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Modify _fetchUserData to get the userId from the provider
  Future<void> _fetchUserData() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false)
          .userId; // Get userId from the provider
      if (userId.isEmpty) {
        _showErrorDialog(context, 'User ID is not set.');
        return;
      }
      print('User ID: $userId');

      final url = 'http://localhost:5000/api/user-details?userId=$userId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userBalance = data['balance'];
          userCurrency = data['currency'];
          isLoading = false;
        });
      } else {
        _showErrorDialog(context, 'Failed to load user data.');
      }
    } catch (e) {
      _showErrorDialog(context, 'Error fetching user data. Please try again.');
    }
  }

  void _fundAccount(BuildContext context, double amount) async {
    if (_selectedCurrency == null || amount <= 0) {
      _showErrorDialog(context, 'Please select a valid currency and amount.');
      return;
    }

    try {
      final userId = Provider.of<UserProvider>(context, listen: false)
          .userId; // Get userId from the provider
      if (userId.isEmpty) {
        _showErrorDialog(context, 'User ID is not set.');
        return;
      }

      print('User ID: $userId');
      final response =
          await _fundAccountAPI(userId, amount, _selectedCurrency!);
      print('Response: $response');

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Account funded with \$${amount.toStringAsFixed(2)} $_selectedCurrency'),
          ),
        );
        _amountController.clear();
        setState(() {
          _selectedCurrency = null;
          _fetchUserData(); // Refresh user data after funding
        });
      } else {
        _showErrorDialog(context, response['message'] ?? 'Funding failed');
      }
    } catch (e) {
      _showErrorDialog(
          context, 'Failed to fund the account. Please try again.');
    }
  }

  Future<Map<String, dynamic>> _fundAccountAPI(
      String userId, double amount, String currency) async {
    final url =
        'http://localhost:5000/api/fund'; // Replace with the correct API URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'user-id': userId, // Pass the userId dynamically from the provider
        },
        body: json.encode({
          'amount': amount,
          'currency': currency,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'error', 'message': 'Failed to fund account'};
      }
    } catch (e) {
      throw Exception('Error during funding process');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fund Account'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Funds to Your Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Current Balance: \$${userBalance?.toStringAsFixed(2)} $userCurrency',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter Amount',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButton<String>(
                    value: _selectedCurrency,
                    hint: const Text("Select Currency"),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCurrency = newValue;
                      });
                    },
                    items: <String>['USD', 'EUR', 'PLN']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final amountText = _amountController.text;
                      if (amountText.isEmpty ||
                          double.tryParse(amountText) == null) {
                        _showErrorDialog(
                            context, 'Please enter a valid amount.');
                      } else {
                        final amount = double.parse(amountText);
                        _fundAccount(context, amount);
                      }
                    },
                    child: const Text('Fund Account'),
                  ),
                ],
              ),
            ),
    );
  }
}
