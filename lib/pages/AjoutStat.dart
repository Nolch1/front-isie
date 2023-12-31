import 'package:flutter/material.dart';
import 'package:isieprojet/pages/Statics.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:isieprojet/AuthProvider.dart';
import 'package:provider/provider.dart';

import 'LoginPage.dart';
class AjoutStatPage extends StatefulWidget {
  @override
  _AjoutStatPageState createState() => _AjoutStatPageState();
}

class _AjoutStatPageState extends State<AjoutStatPage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedHour = '12:00';

  // Map to store controllers for each category
  final Map<String, TextEditingController> controllers = {
    'Males Votes': TextEditingController(),
    'Males Confirmations': TextEditingController(),
    'Females Votes': TextEditingController(),
    'Females Confirmations': TextEditingController(),
    'Old People Votes': TextEditingController(),
    'Old People Confirmations': TextEditingController(),
  };

  Future<void> sendVotes() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      // Handle unauthorized access
      return;
    }
    final userId = authProvider.userId;

    final apiUrl = 'http://localhost:8000/api/addVotes'; // Replace with your actual API endpoint
    final authToken = 'YOUR_AUTH_TOKEN'; // Replace with the user's authentication token

    final Map<String, dynamic> data = {
      'user_id': 11, // Replace with the actual user ID
      'hour': selectedHour,
      'males': int.parse(controllers['Males Votes']!.text),
      'females': int.parse(controllers['Females Votes']!.text),
      'old_people': int.parse(controllers['Old People Votes']!.text),
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {

        print('Votes sent successfully by user ID: $userId');
        _showSuccessAlert();
        print('succed: ${response.body}');
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert'),
              content: Text(
                  'Votes and confirmations must be equal for each group.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        print('Failed to send votes. Status code: ${response.statusCode}');
        // Handle error as needed
      }
    } catch (e) {
      print('Error: $e');
      // Handle error as needed
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        title: null, // Remove the title
        actions: [
          Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300], // Change the color to your preference
            ),
            child: IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.black, // Change the color to your preference
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // Replace LoginPage with your actual login page
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Select menu for hours
                Container(
                  padding: EdgeInsets.only(top: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: selectedHour,
                    dropdownColor: Colors.white,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    items: List.generate(
                      24,
                          (index) {
                        final hour = index < 10 ? '0$index' : '$index';
                        return DropdownMenuItem<String>(
                          value: '$hour:00',
                          child: Text(
                            '$hour:00',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedHour = value!;
                        print('Selected Hour: $selectedHour');
                      });
                    },
                  ),
                ),
                // Text for "Number of Voters"
                SizedBox(height: 20),
                Text(
                  'Number of Voters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                // Rows for Voters
                _buildVoterRow('Males'),
                _buildVoterRow('Females'),
                _buildVoterRow('Old People'),

                // Send Button
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {

                    // Check if votes and confirmations are equal for each group
                    if (_checkVotesConfirmationsEquality('Males') &&
                        _checkVotesConfirmationsEquality('Females') &&
                        _checkVotesConfirmationsEquality('Old People')) {
                      // TODO: Implement logic for sending data
                      sendVotes();


                      // Show success alert


                      // You can also navigate to another page here if needed
                    } else {
                      // Show an alert if votes and confirmations are not equal
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(200, 50),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(color: Colors.red),
                    ),
                    primary: Colors.red,
                  ),
                  child: Text(
                    "Send",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart,
                color: _currentIndex == 0 ? Colors.blue : Colors.grey),
            label: 'AjoutStat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart,
                color: _currentIndex == 1 ? Colors.blue : Colors.grey),
            label: 'Statics',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
            // Navigate to the AjoutStatPage
            // You might want to add more logic here if needed
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StaticsPage()),
              );
              break;
          }
        },
      ),
    );
  }

  // Reusable function to build voter rows
  Widget _buildVoterRow(String title) {
    TextEditingController votesController = controllers[title + ' Votes']!;
    TextEditingController confirmationsController =
    controllers[title + ' Confirmations']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title:',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold, // Set fontWeight to bold
        ),),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text field for votes
            Container(
              width: 100,
              child: TextField(
                controller: votesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Votes',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 10),
            // Text field for confirmations
            Container(
              width: 100,
              child: TextField(
                controller: confirmationsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Confirm',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }

  // Function to check if votes and confirmations are equal for a specific group
  bool _checkVotesConfirmationsEquality(String title) {
    int votes = int.tryParse(controllers[title + ' Votes']!.text) ?? 0;
    int confirmations =
        int.tryParse(controllers[title + ' Confirmations']!.text) ?? 0;
    return votes == confirmations;
  }

  // Function to show a success alert
  void _showSuccessAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Information sent successfully!'),
        );
      },
    );
    // Hide the alert after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Close the alert
    });
  }
}
