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
  final bool isLoggedIn = false;
  ProductsByCategoryPage({required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(isLoggedIn: isLoggedIn),
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

  Future<List<int>> getSpecificPriceProductIds() async {
    String username = '1V7UKH354GJ24FZZVJQ6LNV3FY7VH927';
    String password = '';
    String basicAuth =
        'Basic ' + base64.encode(utf8.encode('$username:$password'));

    http.Response specificPricesResponse = await http.get(
      Uri.parse(
          'http://localhost/prestashop/api/specific_prices?output_format=JSON'),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (specificPricesResponse.statusCode == 200) {
      List<dynamic> specificPriceIds =
          jsonDecode(specificPricesResponse.body)['specific_prices'];
      return specificPriceIds.map<int>((sp) => sp['id']).toList();
    } else {
      print(
          'Failed to fetch specific price IDs. Status code: ${specificPricesResponse.statusCode}');
      return [];
    }
  }

  Future<Map<int, Map<String, dynamic>>?> getSpecificPriceDetails(
      List<int> productIds) async {
    String username = '1V7UKH354GJ24FZZVJQ6LNV3FY7VH927';
    String password = '';
    String basicAuth =
        'Basic ' + base64.encode(utf8.encode('$username:$password'));

    Map<int, Map<String, dynamic>> specificPriceDetails = {};

    for (int productId in productIds) {
      http.Response specificPriceResponse = await http.get(
        Uri.parse(
            'http://localhost/prestashop/api/specific_prices/$productId?output_format=JSON'),
        headers: <String, String>{'authorization': basicAuth},
      );

      if (specificPriceResponse.statusCode == 200) {
        Map<String, dynamic> specificPriceInfo =
            jsonDecode(specificPriceResponse.body)['specific_price'];
        specificPriceDetails[productId] = specificPriceInfo;
      } else {
        print(
            'Failed to fetch specific price details for product ID $productId. Status code: ${specificPriceResponse.statusCode}');
      }
    }

    return specificPriceDetails;
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

      // Fetch specific price product IDs and details
      List<int> specificPriceProductIds = await getSpecificPriceProductIds();
      Map<int, Map<String, dynamic>>? specificPriceDetails =
          await getSpecificPriceDetails(specificPriceProductIds);

      setState(() {
        // Update productList with specific prices
        productList.forEach((product) {
          final productId = product['id'];
          if (specificPriceDetails != null &&
              specificPriceDetails.containsKey(productId)) {
            final specificPriceInfo = specificPriceDetails[productId];
            final regularPrice = double.tryParse(product['price']) ?? 0.0;
            final reduction = specificPriceInfo != null &&
                    specificPriceInfo['reduction'] != null
                ? double.tryParse(specificPriceInfo['reduction']) ?? 0.0
                : 0.0;
            final specificPriceValue = regularPrice * (1 - reduction);
            product['specific_price'] = specificPriceValue.toStringAsFixed(2);
            product['reduction'] = reduction.toStringAsFixed(2);
          }
        });
      });
    } else {
      print(
          'Failed to fetch products. Status code: ${productListResponse.statusCode}');
    }
  }

  Map<int, Uint8List?> imageCache = {}; // Store fetched image data
  Map<int, Uint8List?> productImages = {};

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
      imageCache[imageId] = imageData;
      productImages[imageId] = imageData; // Cache the fetched image data
      return imageData;
    } else {
      print(
          'Failed to fetch image for product ID $productId. Status code: ${imageResponse.statusCode}');
      return null; // Return null if image fetch fails
    }
  }

  bool productHasSpecificPrice(Map<String, dynamic> product) {
    return product['specific_price'] != null;
  }

  String getReductionPercentage(Map<String, dynamic> product) {
    // Assuming that the 'specific_price' value is a percentage reduction
    final reduction = double.tryParse(product['reduction']);
    if (reduction != null) {
      return '-${(reduction * 100).toStringAsFixed(0)}%';
    } else {
      return ''; // Handle the case where 'specific_price' is not a valid percentage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft, // Align to the top-left corner
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
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
                      final Uint8List? productImage = productImages[imageId];
                      final double? reducedPrice = double.tryParse(
                          productList[index]['specific_price'] ?? '');

                      if (productImage != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsPage(
                              product_id: productList[index]['id'],
                              productName: productList[index]['name'][0]
                                  ['value'],
                              price: double.tryParse(
                                      productList[index]['price']) ??
                                  0.0,
                              reducedPrice: reducedPrice ??
                                  0.0, // Pass the reducedPrice parameter
                              productImage: productImage,
                              description: productList[index]['description'][0]
                                  ['value'],
                            ),
                          ),
                        );
                      }
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
                                    return Text('Error loading image');
                                  } else if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    return Image.memory(snapshot.data!);
                                  } else {
                                    return Container();
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
                          top: 0, // Position the chip at the top of the card
                          left: 0,
                          right: 0,
                          child: productHasSpecificPrice(productList[index])
                              ? Chip(
                                  backgroundColor: Colors.red,
                                  label: Text(
                                    getReductionPercentage(productList[index]),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : SizedBox
                                  .shrink(), // If no specific price, use SizedBox
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
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: ' \$${productList[index]['price']}',
                                      style: TextStyle(
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                        fontWeight: FontWeight.bold,
                                        decoration: productList[index]
                                                    ['specific_price'] !=
                                                null
                                            ? TextDecoration.lineThrough
                                            : null, // Crossed out style if specific price exists
                                        // Crossed out style
                                      ),
                                    ),
                                    if (productList[index]['specific_price'] !=
                                        null) // Check if there's a specific price
                                      TextSpan(
                                        text:
                                            ' \$${productList[index]['specific_price']}',
                                        style: TextStyle(
                                          color: Color.fromRGBO(220, 46, 46,
                                              1), // Red color for reduced price
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              16, // Adjust font size as needed
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
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
