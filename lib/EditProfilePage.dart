import 'package:ecommerce_app/common_widgets.dart';
import 'package:ecommerce_app/drawer_content.dart';
import 'package:ecommerce_app/login_page.dart';
import 'package:ecommerce_app/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

class EditProfilePage extends StatefulWidget {
  final int customerId;

  EditProfilePage({required this.customerId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final bool isLoggedIn=false;
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }
  final _formKey = GlobalKey<FormState>();
  late String password;
  late String email;
  late String firstName;
  late String lastName;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final response = await http.get(
      Uri.parse('http://localhost/presta/api/customers/${widget.customerId}?ws_key=HXK91J3162VDCQR8DAZD7Y77PT1Z76WD'),
    );

    if (response.statusCode == 200) {
      final document = xml.parse(response.body);
      setState(() {
        email = document.findAllElements('email').first.text;
        firstName = document.findAllElements('firstname').first.text;
        lastName = document.findAllElements('lastname').first.text;
      });
    } else {
      // Handle error
    }
  }
  Future<void> _updateProfile() async {
    final String secureKey = await _fetchSecureKey();

    final xmlBuilder = xml.XmlBuilder();
    xmlBuilder.processing('xml', 'version="1.0"');
    xmlBuilder.element('prestashop', nest: () {
      xmlBuilder.element('customer', nest: () {

        // Ces éléments peuvent ne pas être nécessaires pour une mise à jour,
        // mais ils sont inclus ici pour correspondre à la structure que vous avez partagée.
        xmlBuilder.element('id', nest: widget.customerId.toString());
        xmlBuilder.element('lastname', nest: lastName);
        xmlBuilder.element('firstname', nest: firstName);
        xmlBuilder.element('passwd', nest: password);  // Incluez le mot de passe ici
        xmlBuilder.element('email', nest: email);
        // Ajoutez d'autres éléments ici si nécessaire.
      });
    });

    final xmlData = xmlBuilder.build().toXmlString();

    final response = await http.put(
      Uri.parse('http://localhost/presta/api/customers/${widget.customerId}?ws_key=HXK91J3162VDCQR8DAZD7Y77PT1Z76WD'),
      headers: {
        'Content-Type': 'application/xml',
      },
      body: xmlData,
    );
    if (response.statusCode == 200) {
      // Profile updated
      print('Profile updated successfully');
    } else {
      // Handle error
      print('Error updating profile: ${response.statusCode}');
      print(response.body);  // Print the response body to debug
    }
  }
  Future<String> _fetchSecureKey() async {
    final response = await http.get(
      Uri.parse('http://localhost/presta/api/customers/${widget.customerId}?ws_key=HXK91J3162VDCQR8DAZD7Y77PT1Z76WD'),
    );

    if (response.statusCode == 200) {
      final document = xml.parse(response.body);
      return document.findAllElements('secure_key').first.text;
    } else {
      throw Exception('Failed to fetch secure_key');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(isLoggedIn: isLoggedIn),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.black, // Arrow icon color
                size: 25,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Center(
                child: Text(
                  'Mes informations',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  initialValue: email,
                  decoration: InputDecoration(
                      labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) {
                    email = value!;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: firstName,
                  decoration: InputDecoration(
                      labelText: 'First Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) {
                    firstName = value!;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: lastName,
                  decoration: InputDecoration(
                      labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) {
                    lastName = value!;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,  // Cachez le texte entré
                  onSaved: (value) {
                    password = value!;
                  },
                ),
                SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    _formKey.currentState!.save();
                    _updateProfile();
                  },
                  child: Text('Sauvegarder'),
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
        )
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

