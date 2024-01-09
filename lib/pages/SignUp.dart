import 'package:flutter/material.dart';
import 'package:isieprojet/components/my_secondbutton.dart';
import 'package:isieprojet/components/my_textfield.dart';
import 'package:http/http.dart' as http;

class SignUp extends StatelessWidget {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void signUp(BuildContext context) async {
    // Prepare data to be sent to the Laravel backend
    Map<String, String> data = {
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'email': emailController.text,
      'password': passwordController.text,
    };

    // Send a POST request to the Laravel backend
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/signup'), // Replace with your actual API endpoint
      body: data,
    );

    // Check the response status
    if (response.statusCode == 200) {
      // If signup is successful, you can navigate to the login page or perform other actions
      Navigator.pop(context);
      print('Response body: ${response.body}');

    } else {
      // If signup fails, you can show an error message
      print('Signup failed. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        title: null, // Remove the title
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Image.asset(
                  'assets/logo.png', // Replace 'logo.png' with your actual image file path
                  width: 200, // Adjust the width as needed
                  height: 200, // Adjust the height as needed
                ),
                SizedBox(height: 20),
                Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15),
                // First Name text field
                MyTextField(
                  controller: firstNameController,
                  hintText: 'First Name',
                  obscureText: false,
                  prefixIcon: Icons.person,
                ),
                SizedBox(height: 10),
                // Last Name text field
                MyTextField(
                  controller: lastNameController,
                  hintText: 'Last Name',
                  obscureText: false,
                  prefixIcon: Icons.person,
                ),
                SizedBox(height: 10),
                // Email text field (previously Username)
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                  prefixIcon: Icons.email, // Change to the appropriate email icon
                ),
                SizedBox(height: 10),
                // Password text field
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  prefixIcon: Icons.lock,
                ),
                SizedBox(height: 10),
                // Confirm Password text field
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                  prefixIcon: Icons.lock,
                ),
                SizedBox(height: 20),
                MyButton(
                  onTap: () => signUp(context),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Navigate back to the login page
                  },
                  child: Text(
                    'Already a member? Log in',
                    style: TextStyle(
                      color: Colors.blue,
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
