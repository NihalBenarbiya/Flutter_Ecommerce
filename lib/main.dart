import 'dart:convert';

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
  }

  Future<void> getData() async {
    String username = 'HXK91J3162VDCQR8DAZD7Y77PT1Z76WD';
    String password = '';
    String basicAuth =
        'Basic ' + base64.encode(utf8.encode('$username:$password'));

    http.Response productListResponse = await http.get(
      Uri.parse('http://localhost/presta/api/products?output_format=JSON'),
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
    String username = '	HXK91J3162VDCQR8DAZD7Y77PT1Z76WD';
    String password = '';
    String basicAuth =
        'Basic ' + base64.encode(utf8.encode('$username:$password'));
    http.Response productInfoResponse = await http.get(
      Uri.parse(
          'http://localhost/presta/api/products/$productId?output_format=JSON'),
      headers: <String, String>{'authorization': basicAuth},
    );

    if (productInfoResponse.statusCode == 200) {
      Map<String, dynamic> productInfo =
          jsonDecode(productInfoResponse.body)['product'];

      // Extract and display relevant product information here
      print('Product ID: ${productInfo['id']}');
      print('Product Name: ${productInfo['name'][0]['value']}');

      setState(() {
        productList.add(productInfo);
      });
      // Add more properties as needed
    } else {
      print(
          'Failed to fetch product info for ID $productId. Status code: ${productInfoResponse.statusCode}');
    }
  }

  List<Widget> buildProductCards() {
    return productList.map((productInfo) {
      double price = double.parse(productInfo['price']);

      return Card(
        child: Column(
          children: [
            ListTile(
              title: Text('Product ID: ${productInfo['id']}'),
              subtitle:
                  Text('Product Name: ${productInfo['name'][0]['value']}'),
            ),
            Text('Price:${price.toStringAsFixed(2)} DH'), // Display price
          ],
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
          'assets/images/logoApp.jpg',
          height: 25, // Ajustez la hauteur selon vos besoins
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

              // Display product cards in a carousel
              SizedBox(
                height: 200, // Adjust the height as needed
                child: CarouselSlider(
                  items: buildProductCards(),
                  options: CarouselOptions(
                      // Customize carousel options if needed
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
