import 'package:flutter/material.dart';

class CategoryProductsPage extends StatelessWidget {
  final int categoryId;

  CategoryProductsPage({required this.categoryId});

  @override
  Widget build(BuildContext context) {
    // Exemple basique : Afficher le nom de la catégorie
    return Scaffold(
      appBar: AppBar(
        title: Text('Produits de la catégorie'),
      ),
      body: Center(
        child: Text('Catégorie ID: $categoryId'),
      ),
    );
  }
}
