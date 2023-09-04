import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'common_widgets.dart';
import 'drawer_content.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final bool isLoggedIn=false;
  final _formKey = GlobalKey<FormState>();
  late String productName;

  Future<void> _searchProduct(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final xmlBuilder = xml.XmlBuilder();
      xmlBuilder.processing('xml', 'version="1.0"');
      xmlBuilder.element('prestashop', nest: () {
        xmlBuilder.element('product', nest: () {
          xmlBuilder.element('name', nest: productName);
        });
      });

      final xmlData = xmlBuilder.build().toXmlString();

      final response = await http.post(
        Uri.parse("http://localhost/presta/api/products?ws_key=HXK91J3162VDCQR8DAZD7Y77PT1Z76WD"),
        headers: {
          'Content-Type': 'application/xml',
        },
        body: xmlData,
      );

      if (response.statusCode == 200) {
        // Traitement de la réponse de l'API
        print(response.body);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Search Failed"),
              content: Text("Failed to search for the product. Please try again."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(isLoggedIn: isLoggedIn),
      drawer: DrawerContent(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
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
                  SizedBox(height: 24),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Chercher produit',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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
                      labelText: 'Product Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      productName = value!;
                    },
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _searchProduct(context),
              child: Text('Search'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CommonFooter(
        currentIndex: 0,
        onTap: (index) {
          // Handle bottom navigation item tap
        },
      ),
    );
  }
}
