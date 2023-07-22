import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: const Color.fromRGBO(59, 59, 59, 1),
        title: const Text('ElectroShop'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: imageUrls.map((url) {
                    int index = imageUrls.indexOf(url);
                    return GestureDetector(
                      onTap: () {
                        _carouselController.jumpToPage(index);
                      },
                      child: Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentCarouselIndex == index
                              ? Color.fromRGBO(
                                  255, 181, 0, 1) // Active dot color
                              : Colors.grey, // Inactive dot color
                        ),
                      ),
                    );
                  }).toList(),
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
        backgroundColor: const Color.fromRGBO(221, 221, 221, 1),
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
            ListTile(
              title: Text(
                'MON COMPTE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person_2_outlined,
                  color: Color.fromRGBO(255, 181, 0, 1)),
              title: Text('Connexion'),
              onTap: () {
                // Action for Service 1
              },
            ),
            ListTile(
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
