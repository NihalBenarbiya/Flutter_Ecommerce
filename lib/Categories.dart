import 'package:flutter/material.dart';
import 'CategoryProductsPage.dart';
import 'ProductsByCategory.dart';
import 'common_widgets.dart';
import 'drawer_content.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Map<String, dynamic>> categoryList = [];
  final bool isLoggedIn=false;

  @override
  void initState() {
    super.initState();
    getCategoryData();
  }

  Future<void> getCategoryData() async {
    String username = 'HXK91J3162VDCQR8DAZD7Y77PT1Z76WD';
    String password = '';
    String basicAuth =
        'Basic ' + base64.encode(utf8.encode('$username:$password'));

    http.Response categoryListResponse = await http.get(
      Uri.parse(
          'http://localhost/presta/api/categories?output_format=JSON'),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (categoryListResponse.statusCode == 200) {
      List<dynamic> categoryIds =
      jsonDecode(categoryListResponse.body)['categories'];
      for (var categoryId in categoryIds) {
        await getCategoryInfo(categoryId['id']);
      }
    } else {
      print(
          'Failed to fetch category list. Status code: ${categoryListResponse.statusCode}');
    }
  }

  Future<void> getCategoryInfo(int categoryId) async {
    String username = 'HXK91J3162VDCQR8DAZD7Y77PT1Z76WD';
    String password = '';
    String basicAuth =
        'Basic ' + base64.encode(utf8.encode('$username:$password'));
    http.Response categoryInfoResponse = await http.get(
      Uri.parse(
          'http://localhost/presta/api/categories/$categoryId?output_format=JSON'),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (categoryInfoResponse.statusCode == 200) {
      Map<String, dynamic> categoryInfo =
      jsonDecode(categoryInfoResponse.body)['category'];

      setState(() {
        categoryList.add(categoryInfo);
      });
    } else {
      print(
          'Failed to fetch category info for ID $categoryId. Status code: ${categoryInfoResponse.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

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
            SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20.0,
                crossAxisSpacing: 20.0,
              ),
              itemCount: categoryList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductsByCategoryPage(
                          categoryId: categoryList[index]['id'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.red, width: 2.0),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          '${categoryList[index]['name'][0]['value']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(59, 59, 59, 1),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                );
              },
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

void main() {
  runApp(MaterialApp(
    home: CategoriesPage(),
  ));
}