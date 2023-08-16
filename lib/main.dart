import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'login_page.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
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
    Navigator.pop(context); // Close the drawer
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
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

    http.Response productListResponse = await http.get(
      Uri.parse('http://localhost/prestashop/api/products?output_format=JSON'),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (productListResponse.statusCode == 200) {
      List<dynamic> productIds =
          jsonDecode(productListResponse.body)['products'];
      for (var productId in productIds) {
        await getProductInfo(productId['id']);
      }
    } else {
      print(
          'Failed to fetch product list. Status code: ${productListResponse.statusCode}');
    }
  }

  Future<void> getProductInfo(int productId) async {
    String username = '1V7UKH354GJ24FZZVJQ6LNV3FY7VH927';
    String password = '';
    String basicAuth =
        'Basic ' + base64.encode(utf8.encode('$username:$password'));

    http.Response productInfoResponse = await http.get(
      Uri.parse(
          'http://localhost/prestashop/api/products/$productId?output_format=JSON'),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (productInfoResponse.statusCode == 200) {
      Map<String, dynamic> productInfo =
          jsonDecode(productInfoResponse.body)['product'];

      http.Response specificPriceResponse = await http.get(
        Uri.parse(
            'http://localhost/prestashop/api/specific_prices/$productId?output_format=JSON'),
        headers: <String, String>{'authorization': basicAuth},
      );

      if (specificPriceResponse.statusCode == 200) {
        Map<String, dynamic> specificPrice =
            jsonDecode(specificPriceResponse.body)['specific_price'];
        double regularPrice = double.parse(productInfo['price']);
        double reduction = double.parse(specificPrice['reduction']);
        double newPrice = regularPrice - (regularPrice * reduction);

        productInfo['reduced_price'] = newPrice;
      }

      setState(() {
        productList.add(productInfo);
      });
    } else {
      print(
          'Failed to fetch product info for ID $productId. Status code: ${productInfoResponse.statusCode}');
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

  // List<Widget> buildProductCards() {
  //   return productList.map((productInfo) {
  //     double price = double.parse(productInfo['price']);
  //     int productId = productInfo['id'];
  //     int imageId = int.tryParse(productInfo['id_default_image'] ?? '') ?? 0;

  //     return AspectRatio(
  //       aspectRatio: 0.8, // Adjust the aspect ratio as needed
  //       child: Card(
  //         elevation: 10,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10.0),
  //           side: BorderSide(color: Colors.blue, width: 2.0),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             Container(
  //               height: 100, // Adjust the image height as needed
  //               child: FutureBuilder<Uint8List?>(
  //                 future: getProductImage(productId, imageId),
  //                 builder: (context, snapshot) {
  //                   if (snapshot.connectionState == ConnectionState.waiting) {
  //                     return CircularProgressIndicator();
  //                   } else if (snapshot.hasError) {
  //                     return Text('Error loading image');
  //                   } else if (snapshot.hasData && snapshot.data != null) {
  //                     return Image.memory(
  //                       snapshot.data!,
  //                       fit: BoxFit
  //                           .cover, // Add this line to control image fitting
  //                     );
  //                   } else {
  //                     return SizedBox();
  //                   }
  //                 },
  //               ),
  //             ),
  //             Padding(
  //               padding: EdgeInsets.symmetric(vertical: 8.0),
  //               child: Text(
  //                 '${productInfo['name'][0]['value']}',
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.blue,
  //                 ),
  //                 textAlign: TextAlign.center,
  //                 overflow: TextOverflow.ellipsis, // Add this line
  //                 maxLines: 2, // Add this line
  //               ),
  //             ),
  //             Expanded(
  //                 child: Container()), // Spacer to push the price to the bottom
  //             Container(
  //               padding: EdgeInsets.all(8.0),
  //               width: double.infinity, // Take the full width
  //               decoration: BoxDecoration(
  //                 color: Colors.blue, // Blue background color
  //                 borderRadius: BorderRadius.circular(10.0),
  //               ),
  //               child: Text(
  //                 '${price.toStringAsFixed(2)} DH',
  //                 style: TextStyle(
  //                   color: Color.fromRGBO(255, 181, 0, 1), // White text color
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }).toList();
  // }

  List<Map<String, dynamic>> categoryList = [];

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
        categoryList.add(categoryInfo);
      });
    } else {
      print(
          'Failed to fetch category info for ID $categoryId. Status code: ${categoryInfoResponse.statusCode}');
    }
  }

  List<Widget> buildCategoryChips() {
    return categoryList.map((categoryInfo) {
      return Chip(
        label: Text(
          '${categoryInfo['name'][0]['value']}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12, // Adjust the font size as needed
            color: Colors.blue,
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
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: const Color.fromRGBO(59, 59, 59, 1),
        title: Image.asset(
          'assets/images/ELECTRO.png',
          height: 160, // Ajustez la hauteur selon vos besoins
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Color.fromRGBO(255, 181, 0, 1.0),
            ),
            onPressed: () {},
          ),
        ],
        iconTheme: IconThemeData(color: Color.fromRGBO(255, 181, 0, 1.0)),
      ),
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
                    double price = double.parse(productInfo['price']);
                    double reducedPrice =
                        productInfo.containsKey('reduced_price')
                            ? productInfo['reduced_price']
                            : price;
                    int productId = productInfo['id'];
                    int imageId =
                        int.tryParse(productInfo['id_default_image'] ?? '') ??
                            0;

                    return Stack(
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
                                '${(price - reducedPrice).toStringAsFixed(2)} DH OFF',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
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
                  items: List.generate(categoryList.length, (index) {
                    return Container(
                      width: 150, // Adjust the width to accommodate the text
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.0, // Adjust horizontal padding as needed
                      ),
                      child: Chip(
                        label: Container(
                          // Wrap the label in a container
                          width: double
                              .infinity, // Allow text to wrap within the chip
                          child: Text(
                            '${categoryList[index]['name'][0]['value']}',
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(59, 59, 59, 1),
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 20,
        unselectedFontSize: 20,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Acceuil',
              backgroundColor: Color.fromRGBO(255, 181, 0, 1)),
          BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              label: 'Categories',
              backgroundColor: Color.fromRGBO(255, 181, 0, 1)),
          BottomNavigationBarItem(
              icon: Icon(Icons.discount_outlined),
              label: 'Offres',
              backgroundColor: Color.fromRGBO(255, 181, 0, 1)),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: 'Panier',
              backgroundColor: Color.fromRGBO(255, 181, 0, 1))
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Color.fromRGBO(
            255, 181, 0, 1), // Add this line to change the selected item color
        unselectedItemColor:
            Colors.white, // Add this line to change the unselected item color
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        child: ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: _closeDrawer,
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
              onTap: _openLoginPage, // Navigate to login page
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
              leading: Icon(Icons.info_outline,
                  color: Color.fromRGBO(255, 181, 0, 1)),
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
      ),
    );
  }
}
