import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import HTTP package
import 'dart:convert'; // For encoding the request body

class RegisterScreen extends StatefulWidget {
  final String apiUrl; // Pass API URL to this screen

  RegisterScreen({Key? key, required this.apiUrl}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _register() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (_formKey.currentState?.validate() ?? false) {
      if (password == confirmPassword) {
        print(
            'Registering user: $name, $email, $password to url ${widget.apiUrl}');

        // Check if email already exists
        final response = await http.get(
          Uri.parse('${widget.apiUrl}/email/$email'),
        );
        print(
            'Response status code: ${response.statusCode}'); // Check status code
        print('Response body: ${response.body}'); // Log the response body

        if (response.statusCode == 200) {
          final existingUser = json.decode(response.body);
          print('Existing user: $existingUser'); // Log existing user
          if (existingUser != null &&
              existingUser['message'] != 'User not found') {
            print('User already exists: $existingUser'); // Log if user exists
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Email already exists')));
          } else {
            // Proceed with registration
            final user = {
              'name': name,
              'email': email,
              'password': password, // Ideally hash the password on the backend
            };
            print('Registering user: $user'); // Log user data

            final registerResponse = await http.post(
              Uri.parse('${widget.apiUrl}/register'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(user),
            );
            print(
                'Register response: ${registerResponse.body}'); // Log response

            if (registerResponse.statusCode == 201) {
              print('Registration successful');
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Registration successful')));
              Navigator.pushReplacementNamed(context, '/login');
            } else {
              print('Registration failed');
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Registration failed')));
            }
          }
        } else {
          print('Failed to check email availability: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to check email availability')));
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Passwords do not match')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
