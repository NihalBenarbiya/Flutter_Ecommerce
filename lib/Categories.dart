import 'package:ecommerce_app/ProductsByCategory.dart';
import 'package:ecommerce_app/drawer_content.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'common_widgets.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final bool isLoggedIn = false;
  final String basicAuth = 'Basic ' + base64.encode(utf8.encode('HXK91J3162VDCQR8DAZD7Y77PT1Z76WD:'));

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    List<Map<String, dynamic>> categoryList = [];

    try {
      final response = await http.get(
        Uri.parse('http://localhost/presta/api/categories?output_format=JSON'),
        headers: <String, String>{'authorization': basicAuth},
      );

      if (response.statusCode == 200) {
        final categories = jsonDecode(response.body)['categories'];
        for (var category in categories) {
          final int id = (category['id'] is String) ? int.parse(category['id']) : category['id'];
          final categoryInfo = await fetchCategoryInfo(id);

          if (categoryInfo['name'][0]['value'].toLowerCase() != 'racine' &&
              categoryInfo['name'][0]['value'].toLowerCase() != 'accueil') {
            categoryList.add(categoryInfo);
          }
        }
      }
    } catch (e) {
      print('Une erreur s\'est produite : $e');
    }

    return categoryList;
  }

  Future<Map<String, dynamic>> fetchCategoryInfo(int id) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/presta/api/categories/$id?output_format=JSON'),
        headers: <String, String>{'authorization': basicAuth},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['category'];
      }
    } catch (e) {
      print('Une erreur s\'est produite : $e');
    }

    return {};
  }

  Future<String> fetchProductImageForCategory(int productId, int imageId) async {
    try {
      final imageUrl = 'http://localhost/presta/api/images/products/$productId/$imageId?ws_key=HXK91J3162VDCQR8DAZD7Y77PT1Z76WD';
      return imageUrl;
    } catch (e) {
      print('Une erreur s\'est produite : $e');
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(isLoggedIn: isLoggedIn),
      drawer: DrawerContent(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  SizedBox(width: 10), // Ajustez l'espacement horizontal si nécessaire
                  Expanded(
                    child: Center(
                      child: Text(
                        'Nos catégories',
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
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Une erreur s\'est produite'),
                    );
                  }

                  final categories = snapshot.data ?? [];

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 3.0,
                      crossAxisSpacing: 3.0,
                      childAspectRatio: 0.75, // Réglez cette valeur selon vos besoins
                    ),

                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final productId = categories[index]['id'];
                      final imageId = categories[index]['id_default_image'] ?? productId; // Remplacez 0 par une valeur par défaut si nécessaire
                      final imageUrl = fetchProductImageForCategory(productId, imageId);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductsByCategoryPage(
                                categoryId: categories[index]['id'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.all(10.0),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                             // borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.black, width: 2.0),
                            ),
                            child: FutureBuilder<String>(
                              future: imageUrl,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }

                                if (snapshot.hasError || !snapshot.hasData) {
                                  return Container(); // Placeholder for no image
                                }

                                final imageUrl = snapshot.data;

                                return Column(
                                  children: [
                                    if (imageUrl != null && imageUrl.isNotEmpty)
                                      Image.network(imageUrl)
                                    else
                                      Container(), // Placeholder for no image
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          categories[index]['name'][0]['value'],
                                          style: TextStyle(
                                            fontSize: 16, // Vous pouvez ajuster la taille de la police selon vos préférences
                                            fontWeight: FontWeight.bold, // Texte en gras
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
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

void main() {
  runApp(MaterialApp(
    home: CategoriesPage(),
  ));
}
