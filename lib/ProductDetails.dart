import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

import 'CartProvider.dart';
import 'common_widgets.dart';
import 'drawer_content.dart';

class ProductDetailsPage extends StatefulWidget {
  final int product_id;
  final String productName;
  final double price;
  final double reducedPrice;
  final Uint8List? productImage;
  final String description;

  ProductDetailsPage({
    required this.product_id,
    required this.productName,
    required this.price,
    required this.reducedPrice,
    required this.productImage,
    required this.description,
  });

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class ProductState {
  int quantity = 1;
  bool showQuantityButtons = false;

  ProductState({required this.quantity, required this.showQuantityButtons});
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _selectedTabIndex = 0;
  final bool isLoggedIn = false;
  bool hasSpecificPrice = false;
  int quantity = 1;
  bool showQuantityButtons = false;
  final cartController = Get.find<CartController>();

  // Use a Map to store the state for each product
  final Map<int, ProductState> productStates = {};

  @override
  void initState() {
    super.initState();
    hasSpecificPrice = widget.reducedPrice > 0.0;
    // Initialize the state for this product
    final state = ProductState(
      quantity: 1,
      showQuantityButtons:
          cartController.getIsAddedToCart(widget.product_id) ?? false,
    );
    productStates[widget.product_id] = state;
  }

  Future<int> fetchCartId() async {
    final response = await http.get(
      Uri.parse(
          "http://localhost/prestashop/api/carts?output_format=JSON&ws_key=1V7UKH354GJ24FZZVJQ6LNV3FY7VH927"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final carts = data['carts'] as List<dynamic>;
      if (carts.isNotEmpty) {
        final cartId = carts[0]['id'] as int;
        return cartId;
      }
    }

    throw Exception("Failed to fetch cart ID");
  }

  Future<int> createCart() async {
    final response = await http.post(
      Uri.parse(
          "http://localhost/prestashop/api/carts?ws_key=1V7UKH354GJ24FZZVJQ6LNV3FY7VH927"),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final newCartId = data['cart']['id'] as int;
      return newCartId;
    }

    throw Exception("Failed to create a new cart");
  }

  Future<int?> getLoggedInCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn');
    final customerId = prefs.getInt('customerId'); // Retrieve the customer ID

    if (isLoggedIn != null && isLoggedIn && customerId != null) {
      return customerId;
    }

    return null;
  }

  Future<void> addToCart() async {
    try {
      // Fetch the cart ID
      final cartId = await fetchCartId();
      // Obtain the customer ID of the currently logged-in user
      final customerId = await getLoggedInCustomerId();

      // Replace these values with actual product ID, attribute ID, and quantity
      final productId = widget.product_id;
      final productAttributeId = 1;

      if (customerId == null) {
        // Handle the case when the customer is not logged in
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Connexion requise"),
              content:
                  Text("Connectez-vous pour ajouter le produit au panier ."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Redirect the user to the login page or handle it as needed
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        return;
      }

      // Build the XML data
      final xmlData = '''
        <prestashop>
        <cart>
          <id_customer>$customerId</id_customer>
          <id_product>$productId</id_product>
          <id_product_attribute>$productAttributeId</id_product_attribute>
          <id_address_delivery>1</id_address_delivery>
          <quantity>$quantity</quantity>
          <id_currency>1</id_currency>
          <id_lang>1</id_lang>
          <delivery_option><![CDATA[{"3":"2"}]]></delivery_option>
          <associations>
            <cart_rows>
            <cart_row>
              <id_product>$productId</id_product>
              <id_product_attribute>$productAttributeId</id_product_attribute>
              <id_address_delivery>1</id_address_delivery>
              <quantity>$quantity</quantity>
              </cart_row>
            </cart_rows>
          </associations>
        </cart>
      </prestashop>
    ''';

      // Define the headers
      final headers = {
        'Content-Type': 'application/xml',
      };

      // Construct the URL
      final apiUrl = Uri.parse(
        "http://localhost/prestashop/api/carts/$cartId?ws_key=1V7UKH354GJ24FZZVJQ6LNV3FY7VH927",
      );

      // Send the POST request
      final response = await http.post(apiUrl, headers: headers, body: xmlData);
      print("Response Body: ${response.body}");
      print("Response Status Code: ${response.statusCode}");

      if (response.statusCode == 201) {
        // Cart item added successfully
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Produit ajoute au panier"),
              content: Text("le produit a ete ajoute a votre panier."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );

        // Create a CartItem based on the product details and quantity
        final cartItem = CartItem(
          productId: widget.product_id,
          productName: widget.productName,
          price: widget.price,
          quantity: quantity,
          productImage: widget.productImage,
        );

        // Access the CartController to add the item to the cart
        final cartController = Get.find<CartController>();

        cartController.addToCart(cartItem);
        // Save the updated quantity to SharedPreferences
        cartController.saveQuantityToSharedPreferences();

        // Save the updated quantity to SharedPreferences
        cartController.saveQuantityToSharedPreferences();

        // Show a snackbar or any other feedback to the user
        Get.snackbar(
          'Ajoute au panier',
          'Produit ajoute au panier',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );

        // Update the state for the current product
        final currentState = productStates[widget.product_id];
        if (currentState != null) {
          setState(() {
            currentState.showQuantityButtons = true;
          });
          cartController.setIsAddedToCart(widget.product_id, true);
          // Update cartController.quantity only if the product is successfully added
          cartController.quantity.value = quantity;
        }
      } else {
        // Handle the error case when adding the cart item fails
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Add to Cart Failed"),
              content:
                  Text("Failed to add the item to the cart. Please try again."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle the error when fetching the cart ID fails
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    // Local state for this specific page
    final currentState = productStates[widget.product_id];

    return Scaffold(
      appBar: CommonAppBar(isLoggedIn: isLoggedIn),
      drawer: DrawerContent(context),
      body: Column(
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
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2.0),
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
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
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
                        Container(
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
                                    text:
                                        ' \$${widget.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                      fontWeight: FontWeight.bold,
                                      decoration: hasSpecificPrice
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  if (hasSpecificPrice)
                                    TextSpan(
                                      text:
                                          ' \$${widget.reducedPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Color.fromRGBO(220, 46, 46, 1),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
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
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: GestureDetector(
              onTap: () {
                addToCart();
                if (currentState != null) {
                  setState(() {
                    currentState.showQuantityButtons = true;
                  });
                }
                cartController.toggleQuantityButtons();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(59, 59, 59, 1),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (currentState != null &&
                              currentState.showQuantityButtons)
                            SizedBox(
                              width: 10, // Adjust the spacing between circles
                            ),
                          if (currentState != null &&
                              currentState.showQuantityButtons)
                            Container(
                              width:
                                  30, // Adjust the size of the circle as needed
                              height:
                                  30, // Adjust the size of the circle as needed
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Center(
                                child: IconButton(
                                  onPressed: () {
                                    cartController.decrementQuantity();
                                  },
                                  icon: Icon(
                                    Icons.remove,
                                    color: Colors
                                        .black, // Change the color if needed
                                  ),
                                ),
                              ),
                            ),
                          if (currentState != null &&
                              currentState.showQuantityButtons)
                            Obx(() => Container(
                                  width:
                                      30, // Adjust the size of the circle as needed
                                  height:
                                      30, // Adjust the size of the circle as needed
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${cartController.quantity.value}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors
                                            .black, // Change the color if needed
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )),
                          if (currentState != null &&
                              currentState.showQuantityButtons)
                            Container(
                              width:
                                  30, // Adjust the size of the circle as needed
                              height:
                                  30, // Adjust the size of the circle as needed
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Center(
                                child: IconButton(
                                  onPressed: () {
                                    cartController.incrementQuantity();
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    color: Colors
                                        .black, // Change the color if needed
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(
                            width:
                                10, // Adjust the spacing between the quantity and text
                          ),
                        ],
                      ),
                      Expanded(
                        // Ensures "Ajouter au panier" text takes up the remaining space
                        child: Center(
                          child: Text(
                            'Ajouter au panier',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.shopping_cart,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
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
                              ? Colors.blue
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
                              ? Colors.blue
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
