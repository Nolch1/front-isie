import 'package:flutter/material.dart';
import 'package:isieprojet/components/my_button.dart';
import 'package:isieprojet/components/my_textfield.dart';
import 'package:isieprojet/pages/AjoutStat.dart';
import 'package:isieprojet/pages/SignUp.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:isieprojet/AuthProvider.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key});

  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method

  // sign user in method
  void signUserIn(BuildContext context) async {
    // Get user input
    String email = emailController.text;
    String password = passwordController.text;

    // Build the request body
    Map<String, String> data = {
      'email': email,
      'password': password,
    };

    // Send a POST request to the Laravel backend
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/login'),
      body: data,
    );

    // Check the response status
    if (response.statusCode == 200) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signUserIn(email, password); // Use provider's method

      // Navigate to the appropriate page based on authentication status
      if (authProvider.isAuthenticated) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AjoutStatPage()),
        );
      } else {
        // If the login fails, you can show an error message
        print('Login failed. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // Wrap with SingleChildScrollView
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),

                // logo
                Image.asset(
                  'assets/logo.png', // Replace 'logo.png' with your actual image file path
                  width: 250, // Adjust the width as needed
                  height: 250, // Adjust the height as needed
                ),

                SizedBox(height: 25),

                // welcome back, you've been missed!
                Text(
                  'Welcome back you\'ve been missed!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: 15),

                // username textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                  prefixIcon: Icons.email,
                ),

                SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  prefixIcon: Icons.lock,
                ),

                SizedBox(height: 20),

                // sign in button
                MyButton(
                  onTap: () => signUserIn(context),
                ),

                SizedBox(height: 10),

                // Not a member? Register now
                GestureDetector(
                  onTap: () {
                    // Navigate to the signup page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUp()),
                    );
                  },
                  child: const Text(
                    'Not a member? Register now',
                    style: TextStyle(
                      color: Colors
                          .blue, // You can change the color to your preference
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
