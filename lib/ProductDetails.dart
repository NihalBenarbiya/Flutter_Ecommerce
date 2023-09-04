import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'common_widgets.dart';
import 'drawer_content.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productName;
  final double price;
  final Uint8List? productImage;
  final String description;

  ProductDetailsPage({
    required this.productName,
    required this.price,
    required this.productImage,
    required this.description,
  });

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _selectedTabIndex = 0;
  final bool isLoggedIn=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(isLoggedIn: isLoggedIn),
      drawer: DrawerContent(context),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: 20.0), // Add space from left and right
            child: Padding(
              padding: EdgeInsets.only(top: 20.0), // Add space from top
              child: Center(
                child: Container(
                  width: double
                      .infinity, // Expand the width to the maximum available
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black, width: 2.0), // Black border
                  ),
                  child: ClipRRect(
                    child:
                        Image.memory(widget.productImage!, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            widget.productName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: 20.0), // Add space on both sides
            child: Row(
              children: [
                Expanded(
                  flex: 2, // 2/3 of the width
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(59, 59, 59, 1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.price.toStringAsFixed(2)} DH',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1, // 1/3 of the width
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: Text(
                        'Disponible',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(
                  59, 59, 59, 1), // Set the background color to black
              borderRadius: BorderRadius.circular(20.0), // Rounded corners
            ),
            margin: EdgeInsets.symmetric(
                horizontal: 20.0), // Add spacing between sides
            child: InkWell(
              onTap: () {
                // Implement your "Add to Cart" functionality here
              },
              borderRadius: BorderRadius.circular(
                  20.0), // Match the container's border radius
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0), // Adjust vertical padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.add, // Use the plus icon
                        color: Colors.red, // Set the icon color to red
                      ),
                    ),
                    Text(
                      'Ajouter au panier',
                      style: TextStyle(
                        color: Colors.red, // Set the text color to red
                        fontSize: 14, // Decrease the font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.shopping_cart, // Use the cart icon
                        color: Colors.red, // Set the icon color to red
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = 0;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTabIndex == 0
                              ? Colors.blue // Color when selected
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _selectedTabIndex == 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = 1;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTabIndex == 1
                              ? Colors.blue // Color when selected
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Fichier Technique',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _selectedTabIndex == 1
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _selectedTabIndex == 0
                    ? Text(
                        widget.description,
                        style: TextStyle(fontSize: 16),
                      )
                    : Text(
                        'Fichier Technique Content',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ),
        ],
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
