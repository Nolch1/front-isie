import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:isieprojet/pages/AjoutStat.dart';
import 'package:isieprojet/AuthProvider.dart';
import 'package:provider/provider.dart';

import 'LoginPage.dart';

class StaticsPage extends StatefulWidget {
  @override
  _StaticsPageState createState() => _StaticsPageState();
}

class _StaticsPageState extends State<StaticsPage> {
  int _currentIndex = 1; // Default to StaticsPage

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, TextEditingController> controllers = {};

  List<Map<String, dynamic>> selectedPeople = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSelectedPeople();
  }

  @override
  Widget build(BuildContext context) {
    // Get user ID from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    // Now you can print the user ID
    print('User ID: $userId');

    for (var person in selectedPeople) {
      controllers['${person['id']} Votes'] = TextEditingController();
      controllers['${person['id']} Confirmations'] = TextEditingController();
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _currentIndex == 0 ? null : Text(''),
        actions: [
          Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.black,
              ),
              onPressed: () {
                _performLogout(context);
              },
            ),
          ),
        ],
      ),
      body: _currentIndex == 0
          ? AjoutStatPage()
          : isLoading
          ? CircularProgressIndicator() // Show a loading indicator
          : selectedPeople.isNotEmpty
          ? SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Text(
                  'Circonscription électorale-Le Centre-le bureau',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            for (var person in selectedPeople)
              _buildNameAndInputs(
                '${person['firstname']} ${person['lastname']}',
                controllers['${person['id']} Votes']!,
                controllers['${person['id']} Confirmations']!,
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size(200, 50),
                padding:
                EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(color: Colors.red),
                ),
                primary: Colors.red,
              ),
              onPressed: () {
                bool success = true;
                for (var person in selectedPeople) {
                  success = success &&
                      _checkVotesAndConfirmations(
                        controllers['${person['id']} Votes']!,
                        controllers['${person['id']} Confirmations']!,
                      );

                }

                if (success) {
                  print("Information sent successfully");
                  _addNotes(userId.toString(), selectedPeople);
                  _showSuccessAlert();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Alert'),
                        content: Text('You need to verify the input fields.'),
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
                }
              },
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
      ): Center(
        child: Text('No data available'), // Show an empty state message
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AjoutStatPage()),
              );
              break;
            case 1:
              break;
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNameDialog(userId.toString()),
        tooltip: 'Add Name',
        child: Icon(Icons.add),
      ),
    );
  }

  // Function to build input fields for a given name
  Widget _buildNameAndInputs(String name, TextEditingController votesController,
      TextEditingController confirmationsController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the name with left padding
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            '$name:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),
        // Row for votes and confirmations, centered
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
        SizedBox(height: 20),
      ],
    );
  }

  // Function to check if votes and confirmations are equal for a given name
  bool _checkVotesAndConfirmations(TextEditingController votesController,
      TextEditingController confirmationsController) {
    // Get the values from the TextFields
    int votes = int.tryParse(votesController.text) ?? 0;
    int confirmations = int.tryParse(confirmationsController.text) ?? 0;

    // Check if votes and confirmations are equal
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
  Future<void> _addNotes(String userId, List<Map<String, dynamic>> selectedPeople) async {
    try {
      for (var person in selectedPeople) {
        final votesController = controllers['${person['id']} Votes'];

        if (votesController != null) {
          final response = await http.post(
            Uri.parse('http://localhost:8000/api/addNotes'),
            body: {
              'user_id': userId,
              'name': '${person['firstname']} ${person['lastname']}',
              'votes': (int.tryParse(votesController.text) ?? 0).toString(),
              'notes': (int.tryParse(votesController.text) ?? 0).toString(), // Include 'notes' field
            },
          );

          if (response.statusCode != 200) {
            print('Failed to add notes for ${person['firstname']} ${person['lastname']}. Status code: ${response.statusCode}');
            print('Response body: ${response.body}');
            // Handle failure, e.g., show an error message
          }
        } else {
          print('Votes controller is null for ${person['firstname']} ${person['lastname']}');
        }
      }

      print('All notes (votes) added successfully');
      // Handle success, e.g., show a success message
      _showSuccessAlert();
    } catch (error) {
      print('Error adding notes (votes): $error');
      // Handle error, e.g., show an error message
    }
  }


  // Function to perform the logout operation
  void _performLogout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.signUserOut(); // Call the signUserOut method
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
  // Function to show the add name dialog
  Future<void> _showAddNameDialog(String userId) async {
    String firstName = '';
    String lastName = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  firstName = value;
                },
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                onChanged: (value) {
                  lastName = value;
                },
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (firstName.isNotEmpty && lastName.isNotEmpty) {
                    _addNameToBackend(userId, firstName, lastName);
                    Navigator.pop(context); // Close the dialog
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to fetch selected people from the backend
  Future<void> _fetchSelectedPeople() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if the user is authenticated before fetching data
    if (!authProvider.isAuthenticated) {
      print('User is not authenticated');
      return; // Return early to prevent fetching data
    }

    final userId = authProvider.userId;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/selectedpeople/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        selectedPeople = List<Map<String, dynamic>>.from(data['selectedPeople']);

        // Initialize controllers for votes, confirmations, and notes
        for (var person in selectedPeople) {
          controllers['${person['id']} Votes'] = TextEditingController();
          controllers['${person['id']} Confirmations'] = TextEditingController();
          controllers['${person['id']} Notes'] = TextEditingController();
        }

        setState(() {
          isLoading = false; // Set isLoading to false when data is loaded
        });
      } else {
        print('Failed to fetch selected people. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }


  // Function to add a name to the backend
  Future<void> _addNameToBackend(String userId, String firstName, String lastName) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/selectedpeople/$userId'),
      body: {
        'firstname': firstName,
        'lastname': lastName,
      },
    );

    if (response.statusCode == 200) {
      print('Name added successfully');
      _fetchSelectedPeople(); // Refresh the list of selected people
    } else {
      print('Failed to add name');
    }
  }
}
