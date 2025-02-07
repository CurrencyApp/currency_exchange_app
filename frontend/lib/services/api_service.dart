import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/balance.dart';

class ApiService {
  // Replace this with your API URL
  final String baseUrl = 'http://10.0.2.2:8000';

  // Fetch user data based on userId
  Future<User> fetchUserData(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      return User.fromMap(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  // Fetch user balance data
  Future<UserBalance> fetchUserBalance(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user_balance/$userId'));

    if (response.statusCode == 200) {
      return UserBalance.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch user balance');
    }
  }
}
