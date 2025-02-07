import 'package:currency_exchange_app/screens/dashboard.dart';
import 'package:currency_exchange_app/screens/exchange_rates.dart'; // Add this import
import 'package:currency_exchange_app/screens/buy_sell_currency.dart';
import 'package:currency_exchange_app/screens/fund.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'services/database_service.dart';
import './screens/login.dart';
import './screens/register.dart';
import './screens/splash_screen.dart';
import './providers/user_provider.dart'; // Import your user provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database connection
  final databaseService = ApiService();

  runApp(MyApp(databaseService));
}

class MyApp extends StatelessWidget {
  final ApiService databaseService;

  MyApp(this.databaseService);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        title: 'Currency Exchange App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/': (context) => SplashScreen(apiUrl: 'http://localhost:5000/api'),
          '/login': (context) =>
              LoginScreen(apiUrl: 'http://localhost:5000/api'),
          '/register': (context) =>
              RegisterScreen(apiUrl: 'http://localhost:5000/api'),
          '/dashboard': (context) => DashboardScreen(),
          '/exchange_rates': (context) => ExchangeRatesScreen(), // New route
          '/buy_sell_currency': (context) =>
              BuySellCurrencyScreen(), // New route
          '/fund': (context) => FundAccountScreen(), // New route
        },
      ),
    );
  }
}
