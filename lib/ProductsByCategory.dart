import 'dart:convert';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'ProductDetails.dart';
import 'common_widgets.dart';
import 'drawer_content.dart';
import 'login_page.dart';

class ProductsByCategoryPage extends StatelessWidget {
  final int categoryId;

  ProductsByCategoryPage({required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      drawer: DrawerContent(context),
      body: SubcategoryList(categoryId: categoryId),
      bottomNavigationBar: CommonFooter(
        currentIndex: 0,
        onTap: (index) {
          // Handle bottom navigation tap if needed
        },
      ),
    );
  }
}

class SubcategoryList extends StatefulWidget {
  final int categoryId;

  SubcategoryList({required this.categoryId});

  @override
  _SubcategoryListState createState() => _SubcategoryListState();
}

class _SubcategoryListState extends State<SubcategoryList> {
  List<Map<String, dynamic>> subcategoryList = [];
  List<Map<String, dynamic>> productList = [];

  @override
  void initState() {
    super.initState();
    getCategoryData();
  }

  Future<void> getCategoryData() async {
    String username = '1V7UKH354GJ24FZZVJQ6LNV3FY7VH927';
    String password = '';
    String basicAuth =
        'Basic ' + base64.encode(utf8.encode('$username:$password'));

    http.Response categoryListResponse = await http.get(
      Uri.parse(
          'http://localhost/prestashop/api/categories&output_format=JSON'),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (categoryListResponse.statusCode == 200) {
      List<dynamic> categoryIds =
          jsonDecode(categoryListResponse.body)['categories'];
      for (var categoryId in categoryIds) {
        await getCategoryInfo(categoryId['id']);
      }

      subcategoryList = subcategoryList
          .where((category) => category['id_parent'] == "${widget.categoryId}")
          .toList();

      setState(() {
        // Update the subcategoryList
        subcategoryList = subcategoryList.toList();
      });

      // Fetch products for the first subcategory by default
      if (subcategoryList.isNotEmpty) {
        getProductData(subcategoryList[0]['id']);
      } else {
        // If there are no subcategories, fetch and display products directly
        getProductData(widget.categoryId);
      }
    } else {
      print(
          'Failed to fetch category list. Status code: ${categoryListResponse.statusCode}');
    }
  }

  Future<void> getCategoryInfo(int categoryId) async {
    String username = '1V7UKH354GJ24FZZVJQ6LNV3FY7VH927';
    String password = '';
    String basicAuth =
        'Basic ' + base64.encode(utf8.encode('$username:$password'));
    http.Response categoryInfoResponse = await http.get(
      Uri.parse(
          'http://localhost/prestashop/api/categories/$categoryId&output_format=JSON'),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (categoryInfoResponse.statusCode == 200) {
      Map<String, dynamic> categoryInfo =
          jsonDecode(categoryInfoResponse.body)['category'];

      setState(() {
        subcategoryList.add(categoryInfo);
      });
    } else {
      print(
          'Failed to fetch category info for ID $categoryId. Status code: ${categoryInfoResponse.statusCode}');
    }
  }

  Future<void> getProductData(int categoryId) async {
    String username = '1V7UKH354GJ24FZZVJQ6LNV3FY7VH927';
    String password = '';
    String basicAuth =
        'Basic ' + base64.encode(utf8.encode('$username:$password'));

    http.Response productListResponse = await http.get(
      Uri.parse('http://localhost/prestashop/api/products?output_format=JSON'),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (productListResponse.statusCode == 200) {
      List<dynamic> products = jsonDecode(productListResponse.body)['products'];
      List<Map<String, dynamic>> filteredProducts = [];

      for (var product in products) {
        int productId = product['id'];
        // Fetch detailed product information using productId
        http.Response productInfoResponse = await http.get(
          Uri.parse(
              'http://localhost/prestashop/api/products/$productId?output_format=JSON'),
          headers: <String, String>{'authorization': basicAuth},
        );

        if (productInfoResponse.statusCode == 200) {
          Map<String, dynamic> productInfo =
              jsonDecode(productInfoResponse.body)['product'];
          if (productInfo['id_category_default'] == categoryId.toString()) {
            filteredProducts.add(productInfo);
          }
        } else {
          print(
              'Failed to fetch product info for ID $productId. Status code: ${productInfoResponse.statusCode}');
        }
      }

      setState(() {
        productList = filteredProducts;
      });
    } else {
      print(
          'Failed to fetch products. Status code: ${productListResponse.statusCode}');
    }
  }

  Map<int, Uint8List?> imageCache = {}; // Store fetched image data

  Future<Uint8List?> getProductImage(int productId, int imageId) async {
    // Check if the image data is already cached
    if (imageCache.containsKey(imageId)) {
      return imageCache[imageId];
    }

    String username = '1V7UKH354GJ24FZZVJQ6LNV3FY7VH927';
    String password = '';
    String basicAuth =
        'Basic ' + base64.encode(utf8.encode('$username:$password'));
    http.Response imageResponse = await http.get(
      Uri.parse(
          'http://localhost/prestashop/api/images/products/$productId/$imageId'),
      headers: <String, String>{
        'authorization': basicAuth,
      },
    );

    if (imageResponse.statusCode == 200) {
      Uint8List? imageData = imageResponse.bodyBytes;
      imageCache[imageId] = imageData; // Cache the fetched image data
      return imageData;
    } else {
      print(
          'Failed to fetch image for product ID $productId. Status code: ${imageResponse.statusCode}');
      return null; // Return null if image fetch fails
    }
  }

  Future<void> navigateToProductDetails(
      BuildContext context, Map<String, dynamic> productInfo) async {
    double price = (productInfo['regular_price'] as double?) ?? 0.0;
    double reducedPrice = (productInfo['reduced_price'] as double?) ?? price;

    // double reducedPrice = productInfo.containsKey('reduced_price')
    //     ? productInfo['reduced_price']
    //     : price;
    int productId = productInfo['id'];
    int imageId = int.tryParse(productInfo['id_default_image'] ?? '') ?? 0;

    Uint8List? productImage = await getProductImage(productId, imageId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(
          productName: productInfo['name'][0]['value'],
          price: reducedPrice,
          productImage: productImage,
          description: productInfo['description'][0]['value'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: subcategoryList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  getProductData(subcategoryList[index]['id']);
                },
                child: Container(
                  width: 150,
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.0,
                  ),
                  child: Chip(
                    label: Container(
                      width: double.infinity,
                      child: Text(
                        '${subcategoryList[index]['name'][0]['value']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color.fromRGBO(59, 59, 59, 1),
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75, // Adjust this for card aspect ratio
              ),
              itemCount: productList.length,
              itemBuilder: (context, index) {
                int productId = productList[index]['id'];
                int imageId = int.tryParse(
                        productList[index]['id_default_image'] ?? '') ??
                    0;

                return Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color: Color.fromRGBO(59, 59, 59, 1),
                      width: 2.0,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to product details page
                      navigateToProductDetails(context, productList[index]);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 180,
                              child: FutureBuilder<Uint8List?>(
                                future: getProductImage(productId, imageId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        'Error loading image'); // Show an error message if image fetch fails
                                  } else if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    return Image.memory(snapshot.data!);
                                  } else {
                                    return Container(); // Display an empty container if no image
                                  }
                                },
                              ),
                            ),
                            Text(
                              productList[index]['name'][0]['value'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(255, 181, 0, 1),
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(59, 59, 59, 1),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                ' ${productList[index]['price']}',
                                style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
