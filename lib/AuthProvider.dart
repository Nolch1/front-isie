import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String _token = ''; // Initialize with empty string
  int _userId = 0; // Initialize with 0

  String get token => _token;
  int get userId => _userId;

  bool get isAuthenticated => _token.isNotEmpty; // Check for non-empty token

  Future<void> signUserIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/login'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _token = responseData['token']['name'] ?? ''; // Access the 'name' property
        _userId = responseData['user_id'] ?? 0;
        notifyListeners();
      } else {
        throw Exception('Login failed');
      }
    } catch (error) {
      // Handle any errors during login
      print(error);
      rethrow; // Rethrow to allow error handling in calling code
    }
  }

  void signUserOut() {
    _token = '';
    _userId = 0;
    notifyListeners();
  }
}
