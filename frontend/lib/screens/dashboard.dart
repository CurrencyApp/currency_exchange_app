import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart'; // Import provider
import '../providers/user_provider.dart'; // Import UserProvider
import '../models/user.dart'; // Import User model
import '../models/balance.dart'; // Import UserBalance model

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> exchangeRates = [];
  bool isLoading = true;
  bool isUserLoading = true;
  String userName = '';
  double userBalance = 0.0;
  String userCurrency = '';

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
    fetchUserData();
  }

  // Fetch user data (name and balance)
  Future<void> fetchUserData() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;

      if (userId.isNotEmpty) {
        print('Fetching user data for user ID: $userId');
        final userResponse = await http.get(
          Uri.parse('http://localhost:5000/api/id/$userId'),
        );

        if (userResponse.statusCode == 200) {
          print('User data fetched successfully');
          final userMap =
              json.decode(userResponse.body) as Map<String, dynamic>;

          // Store the data in separate variables (excluding password)
          final userId = userMap['_id'];
          final userName = userMap['name'];
          final userEmail = userMap['email'];
          final userAdditionalId = userMap['id'];

          print('User ID: $userId');
          print('Name: $userName');
          print('Email: $userEmail');
          print('Additional ID: $userAdditionalId');

          setState(() {
            // Save necessary fields in the widget state
            this.userName = userName;
          });

          // Fetch user balance
          print('Fetching user balance for user ID: $userId');
          final balanceResponse = await http.get(
            Uri.parse('http://localhost:5000/api/balances/$userId'),
          );

          if (balanceResponse.statusCode == 200) {
            final userBalanceData =
                UserBalance.fromJson(json.decode(balanceResponse.body));

            setState(() {
              userBalance = userBalanceData.balance;
              userCurrency = userBalanceData.currency;
              isUserLoading = false;
            });
          } else {
            throw Exception('Failed to fetch user balance');
          }
        } else {
          throw Exception('Failed to fetch user data');
        }
      }
    } catch (e) {
      setState(() {
        isUserLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }

  Future<void> fetchExchangeRates() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.nbp.pl/api/exchangerates/tables/A?format=json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          exchangeRates = data[0]['rates'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch exchange rates');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch userId from the UserProvider
    final userId = Provider.of<UserProvider>(context).userId;

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isUserLoading
                  ? Center(child: CircularProgressIndicator())
                  : Text(
                      'Welcome,   $userName',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              SizedBox(height: 8),
              isUserLoading
                  ? Center(child: CircularProgressIndicator())
                  : Text(
                      'Balance: $userBalance $userCurrency',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                      context, '/fund'); // Navigate to fund screen
                },
                icon: Icon(Icons.money),
                label: Text('Fund My Account'),
              ),
              SizedBox(height: 16),
              Text(
                'Exchange Rates',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 300, // Adjust height to prevent overflow
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Determine number of cards per row based on screen width
                          int crossAxisCount = 1;
                          if (constraints.maxWidth > 600) {
                            crossAxisCount = 2;
                          }
                          if (constraints.maxWidth > 900) {
                            crossAxisCount = 3;
                          }

                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 2.5,
                            ),
                            itemCount: exchangeRates.length,
                            itemBuilder: (context, index) {
                              final rate = exchangeRates[index];
                              return Container(
                                height: 150, // Set your desired minimum height
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  rate['currency'],
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'Rate: ${rate['mid'].toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              'Code: ${rate['code']}',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
              SizedBox(height: 20),
              Text(
                'Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context,
                          '/exchange_rates'); // Navigate to exchange rates
                    },
                    icon: Icon(Icons.bar_chart),
                    label: Text('Exchange Rates'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context,
                          '/buy_sell_currency'); // Navigate to buy/sell currency
                    },
                    icon: Icon(Icons.account_balance_wallet),
                    label: Text('Buy//Sell Currency'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
