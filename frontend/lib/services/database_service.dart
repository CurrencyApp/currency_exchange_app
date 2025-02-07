import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api'; // Your API URL

  // Register user
  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': user['name'],
        'email': user['email'],
        'password': user['password'],
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to register user');
    }
  }

  // Login user
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  // Fetch user by email
  Future<Map<String, dynamic>> fetchUserByEmail(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/email/$email'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('User not found');
    }
  }

  // Fetch user by ID
  Future<Map<String, dynamic>> fetchUserById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/id/$id'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('User not found');
    }
  }

  // Update user balance
  Future<Map<String, dynamic>> updateUserBalance(
      String userId, double amount, String currency) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/balance/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'amount': amount, 'currency': currency}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update balance');
    }
  }
}
