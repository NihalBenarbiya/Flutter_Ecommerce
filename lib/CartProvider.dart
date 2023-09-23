import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common_widgets.dart';
import 'drawer_content.dart';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  RxInt quantity = 1.obs;
  RxInt quantityFromProductDetails = 1.obs;
  var showQuantityButtons = false.obs; // New property

  @override
  void onInit() {
    // Load the quantity from SharedPreferences when the controller is initialized.
    loadQuantityFromSharedPreferences();
    super.onInit();
  }

  void addToCart(CartItem item) {
    cartItems.add(item);
    // Save the updated quantity to SharedPreferences.
    saveQuantityToSharedPreferences();
  }

  void removeFromCart(CartItem item) {
    cartItems.remove(item);
    update(); // Notify listeners that the cart has changed.
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void toggleQuantityButtons() {
    showQuantityButtons.value = !showQuantityButtons.value;
  }

  // Load the quantity from SharedPreferences.
  Future<void> loadQuantityFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuantity = prefs.getInt('quantity');
    if (savedQuantity != null) {
      quantity.value = savedQuantity;
    }
  }

  Future<void> saveQuantityToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('quantity', quantity.value);
  }

  // Method to update quantity from ProductDetailsPage
  void updateQuantityFromProductDetails(int newQuantity) {
    quantityFromProductDetails.value = newQuantity;
  }

  Map<int, bool> addedToCartMap = {}; // Map product_id to isAddedToCart state

  void setIsAddedToCart(int productId, bool value) {
    addedToCartMap[productId] = value;
  }

  bool? getIsAddedToCart(int productId) {
    return addedToCartMap[productId];
  }
}

class CartPage extends StatelessWidget {
  final bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      appBar: CommonAppBar(isLoggedIn: isLoggedIn),
      drawer: DrawerContent(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16.0),
          Text(
            'Mon Panier',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Center(
              child: Obx(() {
                return cartController.cartItems.isEmpty
                    ? Center(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          margin: EdgeInsets.all(8.0),
                          padding: EdgeInsets.all(16.0),
                          height: 200.0, // Set a fixed height
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart,
                                size: 96.0,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                'Votre panier est vide',
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: cartController.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartController.cartItems[index];
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            margin: EdgeInsets.all(8.0),
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    leading: Image.memory(item.productImage!),
                                    title: Text(item.productName),
                                    subtitle: Text(
                                        'Price: \$${item.price.toStringAsFixed(2)}'),
                                    trailing: Text(
                                        'Qty: ${cartController.quantityFromProductDetails}'),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    cartController.removeFromCart(item);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
              }),
            ),
          ),
          if (cartController.cartItems.isNotEmpty)
            Column(
              children: [
                SizedBox(height: 16.0),
                Text(
                  'Vous avez un code promo ?',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () {
                    // Handle "Valider mon panier" button tap.
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: Size(double.infinity, 48.0),
                  ),
                  child: Text(
                    'Valider mon panier',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle "Continuez vos achats" button tap.
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      minimumSize: Size(double.infinity, 48.0),
                    ),
                    child: Text(
                      'Continuez vos achats',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              ],
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

class CartItem {
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final Uint8List? productImage;

  CartItem(
      {required this.productId,
      required this.productName,
      required this.price,
      required this.quantity,
      required this.productImage});
}

void main() {
  runApp(GetMaterialApp(
    home: Scaffold(
      body: CartPage(),
    ),
    initialBinding: BindingsBuilder(() {
      Get.lazyPut<CartController>(() => CartController());
    }),
  ));
}
