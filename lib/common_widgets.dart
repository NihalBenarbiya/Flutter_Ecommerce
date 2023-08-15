import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
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
          onPressed: () {},
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

  CommonFooter({required this.currentIndex, required this.onTap});

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
      onTap: onTap,
      selectedItemColor:
      Color.fromRGBO(255, 181, 0, 1), // Add this line to change the selected item color
      unselectedItemColor: Colors.white, // Add this line to change the unselected item color
    );
  }
}
