import 'dart:convert';
import 'dart:typed_data';

import 'package:ecommerce_app/Aide.dart';
import 'package:ecommerce_app/ProductDetails.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'CartProvider.dart';
import 'ProductsByCategory.dart';
import 'common_widgets.dart';
import 'drawer_content.dart';
import 'login_page.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
  // Initialize the CartController
  Get.put(CartController());
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final bool isLoggedIn = false;
  final List<String> imageUrls = [
    'assets/images/image1.png',
    'assets/images/image2.png',
    'assets/images/image3.png',
  ];

  int _currentCarouselIndex = 0;

  CarouselController _carouselController = CarouselController();

  void _closeDrawer() {
    Navigator.pop(context);
  }

  void _openLoginPage() {
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void _openAidePage() {
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AideWidget()));
  }

  List<Map<String, dynamic>> productList = [];

  @override
  void initState() {
    super.initState();
    getData();
    getCategoryData();
  }

  Future<void> getData() async {
    String username = '1V7UKH354GJ24FZZVJQ6LNV3FY7VH927';
    String password = '';
    String basicAuth =
        'Basic ' + base64.encode(utf8.encode('$username:$password'));

    http.Response specificPriceIdsResponse = await http.get(
      Uri.parse(
          'http://localhost/prestashop/api/specific_prices?output_format=JSON'),
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
          'Failed to fetch specific price IDs. Status code: ${specificPriceIdsResponse.statusCode}');
    }
  }

  Future<void> getProductInfo(int specificPriceId) async {
    String username = '1V7UKH354GJ24FZZVJQ6LNV3FY7VH927';
    String password = '';
    String basicAuth =
        'Basic ' + base64.encode(utf8.encode('$username:$password'));

    http.Response specificPriceResponse = await http.get(
      Uri.parse(
          'http://localhost/prestashop/api/specific_prices/$specificPriceId?output_format=JSON'),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (specificPriceResponse.statusCode == 200) {
      Map<String, dynamic> specificPrice =
      jsonDecode(specificPriceResponse.body)['specific_price'];
      int productId = int.tryParse(specificPrice['id_product'] ?? '') ?? 0;
      double reduction = double.parse(specificPrice['reduction']);

      http.Response productInfoResponse = await http.get(
        Uri.parse(
            'http://localhost/prestashop/api/products/$productId?output_format=JSON'),
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
            'Failed to fetch product info for ID $productId. Status code: ${productInfoResponse.statusCode}');
      }
    } else {
      print(
          'Failed to fetch specific price info for ID $specificPriceId. Status code: ${specificPriceResponse.statusCode}');
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

  List<Map<String, dynamic>> mainCategoryList = [];

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

      // After fetching all categories, filter out those with level_depth equal to 2
      mainCategoryList = mainCategoryList
          .where((category) => category['level_depth'] == "2")
          .toList();
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
        mainCategoryList.add(categoryInfo);
      });
    } else {
      print(
          'Failed to fetch category info for ID $categoryId. Status code: ${categoryInfoResponse.statusCode}');
    }
  }

  Future<void> navigateToProductDetails(
      BuildContext context, Map<String, dynamic> productInfo) async {
    double price = productInfo['regular_price'];
    double reducedPrice = productInfo.containsKey('reduced_price')
        ? productInfo['reduced_price']
        : price;
    int productId = productInfo['id'];
    int imageId = int.tryParse(productInfo['id_default_image'] ?? '') ?? 0;

    Uint8List? productImage = await getProductImage(productId, imageId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(
          product_id: productId,
          productName: productInfo['name'][0]['value'],
          price: price,
          reducedPrice: reducedPrice,
          productImage: productImage,
          description: productInfo['description'][0]['value'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(CartController());
    return Scaffold(
      appBar: CommonAppBar(isLoggedIn: isLoggedIn),
      drawer: DrawerContent(context),
      body: Container(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                child: CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    aspectRatio: 16 / 9,
                    viewportFraction: 1.0,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 2),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentCarouselIndex = index;
                      });
                    },
                  ),
                  items: imageUrls.map((url) {
                    return Image(
                      image: AssetImage(url),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: DotsIndicator(
                  // Use the DotsIndicator widget here
                  dotsCount: imageUrls.length, // Set the number of dots
                  position: _currentCarouselIndex
                      .toDouble(), // Set the current active dot
                  decorator: DotsDecorator(
                    size: const Size.square(9.0),
                    activeSize: const Size(18.0, 9.0),
                    activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    activeColor: Color.fromRGBO(255, 181, 0, 1),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: 15.0), // Adds space from left and right
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: Colors.red,
                    width: 2.0,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'BON PLANS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'LES MEILLEURS PROMOS',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20), // Add some spacing
              SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    aspectRatio: 6 / 4,
                    viewportFraction: 0.5,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 2),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                  ),
                  items: productList.map((productInfo) {
                    double price = productInfo['regular_price'];
                    double reducedPrice =
                    productInfo.containsKey('reduced_price')
                        ? productInfo['reduced_price']
                        : price;
                    int productId = productInfo['id'];
                    int imageId =
                        int.tryParse(productInfo['id_default_image'] ?? '') ??
                            0;

                    return GestureDetector(
                      onTap: () {
                        navigateToProductDetails(context, productInfo);
                      },
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: Color.fromRGBO(59, 59, 59, 1),
                                width: 2.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 180,
                                  child: FutureBuilder<Uint8List?>(
                                    future: getProductImage(productId, imageId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text('Error loading image');
                                      } else if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        return Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        );
                                      } else {
                                        return SizedBox();
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  '${productInfo['name'][0]['value']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(255, 181, 0, 1),
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                Spacer(),
                                Container(
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
                              ],
                            ),
                          ),
                          if (reducedPrice != price)
                            Positioned(
                              top: 0,
                              child: Chip(
                                backgroundColor: Colors.red,
                                label: Text(
                                  '-${productInfo['reduction_percentage']}%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment:
                    Alignment.centerLeft, // Aligns the Divider to the left
                    children: [
                      Text(
                        'NOS CATEGORIES',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                      Divider(
                        color: Colors.red, // Line color
                        thickness: 1, // Thickness of the line
                        height: 20, // Adjust the height of the line
                        indent: 150, // Adjust the indentation of the line
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(
                height: 80,
                width: double.infinity,
                child: CarouselSlider(
                  items: List.generate(mainCategoryList.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductsByCategoryPage(
                              categoryId: mainCategoryList[index]['id'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 150, // Adjust the width to accommodate the text
                        padding: EdgeInsets.symmetric(
                          horizontal:
                          6.0, // Adjust horizontal padding as needed
                        ),
                        child: Chip(
                          label: Container(
                            width: double
                                .infinity, // Allow text to wrap within the chip
                            child: Text(
                              '${mainCategoryList[index]['name'][0]['value']}',
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
                  }),
                  options: CarouselOptions(
                    viewportFraction:
                    0.3, // Adjust to smaller value for tighter spacing
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 2),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                  ),
                ),
              ),
            ],
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