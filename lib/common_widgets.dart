import 'package:ecommerce_app/Categories.dart';
import 'package:ecommerce_app/Offres.dart';
import 'package:ecommerce_app/Recherche.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'CartProvider.dart';

import 'main.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn; // Add this property

  CommonAppBar({required this.isLoggedIn});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      backgroundColor: const Color.fromRGBO(59, 59, 59, 1),
      title: Image.asset(
        'assets/images/logoApp.jpg',
        height: 25,
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.search,
            color: Color.fromRGBO(255, 181, 0, 1.0),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChercherPage()),
            );
          },
        ),
      ],
      iconTheme: IconThemeData(color: Color.fromRGBO(255, 181, 0, 1.0)),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class CommonFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CommonFooter({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color.fromRGBO(59, 59, 59, 1),
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 20,
      unselectedFontSize: 20,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Acceuil',
          backgroundColor: Color.fromRGBO(255, 181, 0, 1),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          label: 'Categories',
          backgroundColor: Color.fromRGBO(255, 181, 0, 1),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.discount_outlined),
          label: 'Offres',
          backgroundColor: Color.fromRGBO(255, 181, 0, 1),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'Panier',
          backgroundColor: Color.fromRGBO(255, 181, 0, 1),
        ),
      ],
      onTap: (index) {
        onTap(index); // Call the provided onTap callback
        // You can also add custom navigation logic here based on the index
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoriesPage()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OffresPage()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartPage()),
            );
            break;
          default:
          // Handle other cases
        }
      },
      selectedItemColor: Color.fromRGBO(255, 181, 0, 1),
      unselectedItemColor:
          Colors.white, // Add this line to change the unselected item color
    );
  }
}
