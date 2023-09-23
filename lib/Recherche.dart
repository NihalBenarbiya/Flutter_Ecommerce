import 'dart:convert';
import 'dart:typed_data';
import 'package:ecommerce_app/AppBarRecherche.dart';
import 'package:ecommerce_app/common_widgets.dart';
import 'package:ecommerce_app/drawer_content.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class ChercherPage extends StatefulWidget {
  @override
  _ChercherPageState createState() => _ChercherPageState();
}

class _ChercherPageState extends State<ChercherPage> {
  final bool isLoggedIn = false;
  TextEditingController _searchController = TextEditingController();
  String _result = "";
  List<Product> productList = [];

  @override
  void initState() {
    super.initState();
    searchProduct(); // Appeler la méthode searchProduct lors de l'initialisation du widget
  }

  Future<void> searchProduct() async {
    try {
      final String baseUrl = "http://localhost/prestashop/api/products";
      final String apiKey = "1V7UKH354GJ24FZZVJQ6LNV3FY7VH927";

      final String keyword = _searchController.text.trim().toLowerCase();

      final String url = "$baseUrl?ws_key=$apiKey"; // obtenir tous les produits

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final xmlDoc = xml.XmlDocument.parse(response.body);
        final products = xmlDoc.findAllElements("product");

        productList.clear();

        for (var product in products) {
          String id = product.getAttribute("id") ?? "";
          await getProductDetails(id); // obtenir les détails du produit
        }

        // Filtre les produits par mot clé si un mot clé est entré
        if (keyword.isNotEmpty) {
          productList = productList
              .where((product) =>
                  product.name?.toLowerCase().contains(keyword) ?? false)
              .toList();
        }

        setState(() {
          if (productList.isEmpty) {
            _result = "Aucun produit trouvé!";
          } else {
            _result = ""; // Aucun message si des produits sont trouvés
          }
        });
      } else {
        setState(() {
          _result = "Erreur lors de la recherche du produit.";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Une erreur s'est produite: $e";
      });
    }
  }

  Future<void> getProductDetails(String productId) async {
    try {
      final String baseUrl =
          "http://localhost/prestashop/api/products/$productId";
      final String apiKey = "1V7UKH354GJ24FZZVJQ6LNV3FY7VH927";
      final String url = "$baseUrl?ws_key=$apiKey";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final xmlDoc = xml.XmlDocument.parse(response.body);
        final productName = xmlDoc.findAllElements("name").first.text;
        final productPrice = xmlDoc.findAllElements("price").first.text;
        final imageId = xmlDoc
            .findAllElements("id_default_image")
            .first
            .text; // Récupérer l'ID de l'image

        setState(() {
          productList.add(Product(
              id: productId,
              name: productName,
              price: productPrice,
              imageId: imageId));
        });
      }
    } catch (e) {
      print("Error fetching product details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarRecherche(isLoggedIn: isLoggedIn),
      drawer: DrawerContent(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                  SizedBox(height: 24),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Chercher produits',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    cursorColor: Color.fromRGBO(255, 181, 0, 1),
                    decoration: InputDecoration(
                      labelText: 'Nom du produit',
                      labelStyle: TextStyle(
                          color: Colors
                              .black), // Ici, mettez la couleur que vous voulez
                      hintText: 'Entrez le nom du produit',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(255, 181, 0, 1), width: 2.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: searchProduct,
                  child: Container(
                    width: 56, // Largeur du bouton
                    height: 56, // Hauteur du bouton
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 181, 0, 1),
                      shape: BoxShape.circle, // Forme circulaire
                    ),
                    child: Center(
                      child: Icon(
                        Icons.search,
                        color: Colors.white, // Couleur de l'icône
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 16),
            Center(
              // Ajoutez ce widget pour centrer le texte
              child: Text(
                _result,
                style: TextStyle(
                  fontWeight: _result == "Aucun produit trouvé!"
                      ? FontWeight.bold
                      : FontWeight.normal, // En gras si "Pas de résultats"
                  color: _result == "Aucun produit trouvé!"
                      ? Colors.grey
                      : Colors.black, // Gris si "Pas de résultats"
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  final product = productList[index];
                  final imageUrl =
                      "http://localhost/prestashop/api/images/products/${product.id}/${product.imageId}?ws_key=1V7UKH354GJ24FZZVJQ6LNV3FY7VH927";
                  return Card(
                    elevation: 5, // Réglez l'élévation comme vous le souhaitez
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Container(
                      height: 150, // Hauteur du Card
                      child: Row(
                        children: [
                          if (product.imageId != null)
                            Image.network(imageUrl, height: 100, width: 100),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  " ${product.name ?? 'Chargement...'}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  "${product.price ?? "Chargement..."}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.shopping_cart),
                            color: Color.fromRGBO(255, 181, 0, 1),
                            onPressed: () {
                              // Ajouter au panier
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CommonFooter(
        currentIndex: 0,
        onTap: (index) {
          // Handle bottom navigation item tap
        },
      ),
    );
  }
}

class Product {
  final String id;
  final String? name;
  final String? price;
  final String? imageId; // Nouveau champ pour l'ID de l'image

  Product({
    required this.id,
    this.name,
    this.price,
    this.imageId, // Initialiser dans le constructeur
  });
}

void main() {
  runApp(MaterialApp(home: ChercherPage()));
}
