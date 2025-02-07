import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import the provider package
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/user_provider.dart'; // Import UserProvider

class BuySellCurrencyScreen extends StatefulWidget {
  @override
  _BuySellCurrencyScreenState createState() => _BuySellCurrencyScreenState();
}

class _BuySellCurrencyScreenState extends State<BuySellCurrencyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final String nbpApiUrl = 'https://api.nbp.pl/api/exchangerates/tables/A/';
  final String transactionApiUrl = 'http://localhost:5000/api/transactions';
  List<Map<String, dynamic>> _exchangeRates = [];
  String? _selectedCurrency;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
  }

  Future<void> fetchExchangeRates() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(nbpApiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final rates = data[0]['rates'] as List<dynamic>;
        setState(() {
          _exchangeRates = rates
              .map((rate) => {
                    'currency': rate['code'],
                    'rate': rate['mid'],
                  })
              .toList();
          _selectedCurrency =
              _exchangeRates.isNotEmpty ? _exchangeRates[0]['currency'] : null;
        });
      } else {
        throw Exception('Failed to fetch exchange rates');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching exchange rates.'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> processTransaction(
      double amount, String currency, String type, String userId) async {
    try {
      print('Processing transaction... $amount, $currency, $type, $userId');
      print('url: $transactionApiUrl');
      final response = await http.post(
        Uri.parse('$transactionApiUrl/$type'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId, // Include the userId
          'amount': amount,
          'currency': currency,
          'type': type,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Transaction successful!'),
        ));
      } else {
        throw Exception('Transaction failed');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Transaction failed.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).userId;

    return Scaffold(
      appBar: AppBar(title: Text('Buy/Sell Currency')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    items: _exchangeRates
                        .map<DropdownMenuItem<String>>((rate) =>
                            DropdownMenuItem<String>(
                              value: rate['currency'] as String,
                              child:
                                  Text('${rate['currency']} - ${rate['rate']}'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrency = value;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Select Currency'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Amount'),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final double? amount =
                              double.tryParse(_amountController.text);
                          if (amount != null &&
                              _selectedCurrency != null &&
                              userId.isNotEmpty) {
                            processTransaction(
                                amount, _selectedCurrency!, 'buy', userId);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Invalid input or missing userId.'),
                            ));
                          }
                        },
                        child: Text('Buy'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final double? amount =
                              double.tryParse(_amountController.text);
                          if (amount != null &&
                              _selectedCurrency != null &&
                              userId.isNotEmpty) {
                            processTransaction(
                                amount, _selectedCurrency!, 'sell', userId);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Invalid input or missing userId.'),
                            ));
                          }
                        },
                        child: Text('Sell'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
