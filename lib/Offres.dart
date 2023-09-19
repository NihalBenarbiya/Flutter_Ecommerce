import 'dart:convert';
import 'dart:typed_data';

import 'package:ecommerce_app/Recherche.dart';
import 'package:ecommerce_app/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'ProductDetails.dart';
import 'drawer_content.dart';

class OffresPage extends StatefulWidget {

  @override
  State<OffresPage> createState() => _OffresPageState();
}

class _OffresPageState extends State<OffresPage> {
  final List<Map<String, dynamic>> productList = [];
  final bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    String username = 'HXK91J3162VDCQR8DAZD7Y77PT1Z76WD';
    String password = '';
    String basicAuth =
        'Basic ' + base64.encode(utf8.encode('$username:$password'));

    http.Response specificPriceIdsResponse = await http.get(
      Uri.parse(
          'http://localhost/presta/api/specific_prices?output_format=JSON'),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (specificPriceIdsResponse.statusCode == 200) {
      List<dynamic> specificPriceIds =
      jsonDecode(specificPriceIdsResponse.body)['specific_prices'];
      for (var specificPriceId in specificPriceIds) {
        await getProductInfo(specificPriceId['id']);
      }
    } else {
      print(
          'Failed to fetch specific price IDs. Status code: ${specificPriceIdsResponse
              .statusCode}');
    }
  }

  Future<void> getProductInfo(int specificPriceId) async {
    String username = 'HXK91J3162VDCQR8DAZD7Y77PT1Z76WD';
    String password = '';
    String basicAuth =
        'Basic ' + base64.encode(utf8.encode('$username:$password'));

    http.Response specificPriceResponse = await http.get(
      Uri.parse(
          'http://localhost/presta/api/specific_prices/$specificPriceId?output_format=JSON'),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (specificPriceResponse.statusCode == 200) {
      Map<String, dynamic> specificPrice =
      jsonDecode(specificPriceResponse.body)['specific_price'];
      //int productId = int.tryParse(specificPrice['id_product'] ?? '') ?? 0;
      int productId = specificPrice['id_product'] ?? '' ?? 0;
      double reduction = double.parse(specificPrice['reduction']);

      http.Response productInfoResponse = await http.get(
        Uri.parse(
            'http://localhost/presta/api/products/$productId?output_format=JSON'),
        headers: <String, String>{'authorization': basicAuth},
      );

      if (productInfoResponse.statusCode == 200) {
        Map<String, dynamic> productInfo =
        jsonDecode(productInfoResponse.body)['product'];

        setState(() {
          double regularPrice = double.parse(productInfo['price']);
          double newPrice = regularPrice * (1 - reduction);

          productInfo['regular_price'] = regularPrice;
          productInfo['reduced_price'] = newPrice;
          productInfo['reduction_percentage'] = reduction * 100;

          productList.add(productInfo);
        });
      } else {
        print(
            'Failed to fetch product info for ID $productId. Status code: ${productInfoResponse
                .statusCode}');
      }
    } else {
      print(
          'Failed to fetch specific price info for ID $specificPriceId. Status code: ${specificPriceResponse
              .statusCode}');
    }
  }

  Map<int, Uint8List?> imageCache = {}; // Store fetched image data

  Future<Uint8List?> getProductImage(int productId, int imageId) async {
    // Check if the image data is already cached
    if (imageCache.containsKey(imageId)) {
      return imageCache[imageId];
    }

    String username = 'HXK91J3162VDCQR8DAZD7Y77PT1Z76WD';
    String password = '';
    String basicAuth =
        'Basic ' + base64.encode(utf8.encode('$username:$password'));
    http.Response imageResponse = await http.get(
      Uri.parse(
          'http://localhost/presta/api/images/products/$productId/$imageId'),
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
          'Failed to fetch image for product ID $productId. Status code: ${imageResponse
              .statusCode}');
      return null; // Return null if image fetch fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(isLoggedIn: isLoggedIn),
      drawer: DrawerContent(context),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 3.0,
              crossAxisSpacing: 3.0,
              childAspectRatio: 0.75, // Adjust this for card aspect ratio
            ),
            itemCount: productList.length,
            itemBuilder: (context, index) {
              double price = productList[index]['regular_price'];
              double reducedPrice =
              productList[index].containsKey('reduced_price')
                  ? productList[index]['reduced_price']
                  : price;
              int productId = productList[index]['id'];
              int imageId = productList[index]['id_default_image'] ?? '';

              return Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  //borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                    color: Color.fromRGBO(59, 59, 59, 1),
                    width: 2.0,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to product details page
                    // navigateToProductDetails(context, productList[index]);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 160,
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
                        top: 0,
                        child: Chip(
                          backgroundColor: Colors.red,
                          label: Text(
                            '-${productList[index]['reduction_percentage']
                                .toInt()}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(59, 59, 59, 1),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${price.toStringAsFixed(2)} DH',
                                style: TextStyle(
                                  decoration: reducedPrice != price
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: Color.fromRGBO(255, 181, 0, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                reducedPrice != price
                                    ? '${reducedPrice.toStringAsFixed(2)} DH'
                                    : '',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
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
      bottomNavigationBar: CommonFooter(
        currentIndex: 0,
        onTap: (index) {
          // Handle bottom navigation tap if needed
        },
      ),
    );
  }
}
  class Product {
  final String id;
  final String? name;
  final String? price;
  final String? imageId;  // Nouveau champ pour l'ID de l'image

  Product({
  required this.id,
  this.name,
  this.price,
  this.imageId,  // Initialiser dans le constructeur
  });
  }

  void main() {
  runApp(MaterialApp(home: ChercherPage()));
  }
