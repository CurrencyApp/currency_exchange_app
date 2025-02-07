import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';

class SplashScreen extends StatelessWidget {
  final String apiUrl;

  SplashScreen({Key? key, required this.apiUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Currency Exchange App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to LoginScreen with apiUrl
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(apiUrl: apiUrl),
                  ),
                );
              },
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to RegisterScreen with apiUrl
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterScreen(apiUrl: apiUrl),
                  ),
                );
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
