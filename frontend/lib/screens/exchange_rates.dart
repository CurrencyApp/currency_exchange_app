import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRatesScreen extends StatefulWidget {
  const ExchangeRatesScreen({super.key});

  @override
  State<ExchangeRatesScreen> createState() => _ExchangeRatesScreenState();
}

class _ExchangeRatesScreenState extends State<ExchangeRatesScreen> {
  List<dynamic> exchangeRates = [];
  Map<String, double> previousRates = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
  }

  Future<void> fetchExchangeRates() async {
    try {
      // Fetch current rates
      final currentResponse = await http.get(
        Uri.parse('https://api.nbp.pl/api/exchangerates/tables/A?format=json'),
      );

      // Fetch previous day's rates
      final previousResponse = await http.get(
        Uri.parse(
          'https://api.nbp.pl/api/exchangerates/tables/A/last/2?format=json',
        ),
      );

      if (currentResponse.statusCode == 200 &&
          previousResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        final previousData = json.decode(previousResponse.body);

        // Parse current rates
        final currentRates = currentData[0]['rates'];
        // Parse previous rates
        final previousRatesList = previousData[0]['rates'];

        // Convert previous rates into a map for easy lookup
        final previousRatesMap = {
          for (var rate in previousRatesList)
            rate['code'] as String: rate['mid'] as double
        };

        setState(() {
          exchangeRates = currentRates;
          previousRates = previousRatesMap;
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

  double calculatePerformance(String code, double currentRate) {
    if (previousRates.containsKey(code)) {
      final previousRate = previousRates[code]!;
      return ((currentRate - previousRate) / previousRate) * 100;
    }
    return 0.0; // Default performance if no previous rate is found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Rates & Performance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: exchangeRates.length,
                itemBuilder: (context, index) {
                  final rate = exchangeRates[index];
                  final performance = calculatePerformance(
                    rate['code'],
                    rate['mid'],
                  );

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rate['currency'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Code: ${rate['code']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current Rate: ${rate['mid'].toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Performance: ${performance.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  performance > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
