import 'package:ecommerce_app/drawer_content.dart';
import 'package:ecommerce_app/main.dart';
import 'package:flutter/material.dart';

import 'common_widgets.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  late String email;
  late String password;
  late String firstName;
  late String lastName;
  late String confirmPassword;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Implement your form submission logic here

      // For example, you might want to navigate to the next page:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), // Replace with your desired next page
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      drawer: DrawerContent(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 24),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Center(
                    child: Text(
                      'Inscrivez-vous!',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: Image.asset(
                'assets/images/logoApp.jpg',
                height: 90,
              ),
            ),
            SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      lastName = value!;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      firstName = value!;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      email = value!;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      password = value!;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != password) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      confirmPassword = value!;
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _submitForm(context),
                    child: Text('S\'inscrire'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange,
                      fixedSize: Size(390, 49),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CommonFooter(
        currentIndex: 0,
        onTap: (index) {
          // Handle bottom navigation tap if needed
        },
      ),
    );
  }

}

