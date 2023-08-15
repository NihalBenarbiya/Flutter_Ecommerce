import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'RegistrationPage.dart';
import 'common_widgets.dart';
import 'main.dart';
import 'package:xml/xml.dart' as xml;

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      drawer: _buildDrawer(context),
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
                    size: 28,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Center(
                    child: Text(
                      'Connectez-vous!',
                      style: TextStyle(
                        fontSize: 28,
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
                height: 100,
              ),
            ),
            SizedBox(height: 24),
            LoginForm(),
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

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      child: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const ListTile(
            title: Text(
              'MON COMPTE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_2_outlined,
                color: Color.fromRGBO(255, 181, 0, 1)),
            title: Text('Connexion'),
            onTap: () {
              Navigator.pop(context);
              //_openLoginPage(context);
            },
          ),
          const ListTile(
            title: Text(
              'NOS SERVICES',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.chat, color: Color.fromRGBO(255, 181, 0, 1)),
            title: Text('Besoin d\'aide ?'),
            onTap: () {
              // Action for Service 1
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet_outlined,
                color: Color.fromRGBO(255, 181, 0, 1)),
            title: Text('Conditions generale de vente'),
            onTap: () {
              // Action for Service 2
            },
          ),
          ListTile(
            leading: Icon(Icons.house_outlined,
                color: Color.fromRGBO(255, 181, 0, 1)),
            title: Text('Nos Magasins'),
            onTap: () {
              // Action for Service 2
            },
          ),
          ListTile(
            leading: Icon(Icons.discount_outlined,
                color: Color.fromRGBO(255, 181, 0, 1)),
            title: Text('Nos Marques'),
            onTap: () {
              // Action for Service 2
            },
          ),
          ListTile(
            title: Text(
              'PLUS D\'INFO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.share, color: Color.fromRGBO(255, 181, 0, 1)),
            title: Text('Partager l\'application'),
            onTap: () {
              // Action for Info 1
            },
          ),
          ListTile(
            leading:
                Icon(Icons.info_outline, color: Color.fromRGBO(255, 181, 0, 1)),
            title: Text('Qui Sommes-Nous ?'),
            onTap: () {
              // Action for Info 2
            },
          ),
          ListTile(
            title: Text(
              'SUIVEZ-NOUS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    // Action for Facebook
                  },
                  child: Icon(Icons.facebook),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    // Action for Instagram
                  },
                  child: Icon(Icons.facebook),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    // Action for Téléphone
                  },
                  child: Icon(Icons.phone),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
Future<bool> loginToPrestaShop(String email, String password, int customerId) async {
  final url = 'http://localhost/presta/api/customers/$customerId?ws_key=HXK91J3162VDCQR8DAZD7Y77PT1Z76WD';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final xmlDoc = xml.XmlDocument.parse(response.body);
    print(response.body);

    final customers = xmlDoc.findAllElements('customer');
    bool loggedIn = false;

    for (final customer in customers) {
      final customerEmailElement = customer.findElements('email').first;
      final customerPasswordElements = customer.findElements('passwd');

      if (customerPasswordElements.isNotEmpty) {
        final customerPasswordElement = customerPasswordElements.first;
        final customerEmail = customerEmailElement.text;
        final customerPassword = customerPasswordElement.text;

        if (customerEmail == email && customerPassword == password) {
          loggedIn = true;
          break; // Exit the loop once a match is found
        }
      }
    }

    return loggedIn; // Return the result
  } else {
    return false; // Login failure
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String passwd = '';
  bool _isPasswordVisible = false;
  bool _loginError = false;
  Future<List<int>> getCustomerIds() async {
    final url = 'http://localhost/presta/api/customers?ws_key=HXK91J3162VDCQR8DAZD7Y77PT1Z76WD';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final xmlDoc = xml.XmlDocument.parse(response.body);
      final customers = xmlDoc.findAllElements('customer');

      List<int> customerIds = [];

      for (final customer in customers) {
        final customerIdAttribute = customer.getAttribute('id');
        if (customerIdAttribute != null) {
          customerIds.add(int.parse(customerIdAttribute));
        }
      }

      return customerIds;
    } else {
      return [];
    }
  }



  int currentCustomerId = 1; // ID de départ

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      List<int> customerIds = await getCustomerIds();

      bool loggedIn = false;

      for (int customerId in customerIds) {
        loggedIn = await loginToPrestaShop(email, passwd, customerId);

        if (loggedIn) {
          break; // Sortir de la boucle si la connexion réussit
        }
      }
      if (loggedIn) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Connexion réussie"),
              content: Text("Vous êtes maintenant connecté."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()), // Redirige vers la HomePage
                    );
                  },
                  child: Text("Fermer"),
                ),
              ],
            );
          },
        );
        setState(() {
          _loginError = false;
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Erreur de connexion"),
              content: Text("Email ou mot de passe incorrect."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Fermer"),
                ),
              ],
            );
          },
        );
        setState(() {
          _loginError = true;
        });
      }
    }
  }
  void _navigateToRegistrationPage() {
    Navigator.push(
      context as BuildContext,
      MaterialPageRoute(builder: (context) => RegistrationPage()),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
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
              passwd = value!;
            },
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _submitForm(context), // Pass the context here
            child: Text('Login'),
            style: ElevatedButton.styleFrom(
              primary: Colors.orange,
              fixedSize: Size(390, 49),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),

          SizedBox(height: 16),
          TextButton(
            onPressed: _navigateToRegistrationPage,
            child: Text(
              "Pas de compte ? Créer un !",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(111, 159, 236, 0.8666666666666667),
              ),
            ),
          ),
          Column(
            children: [
              if (_loginError)
                Text(
                  'Email ou mot de passe incorrect.',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                )
              else
                SizedBox.shrink(), // Empty widget when no error
            ],
          ),


        ],
      ),
    );
  }
}

