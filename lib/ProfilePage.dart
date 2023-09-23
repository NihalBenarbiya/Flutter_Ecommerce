import 'package:ecommerce_app/EditProfilePage.dart';
import 'package:ecommerce_app/common_widgets.dart';
import 'package:ecommerce_app/drawer_content.dart';
import 'package:ecommerce_app/login_page.dart';
import 'package:ecommerce_app/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final bool isLoggedIn=false;
  String? userEmail;
  int? customerId;  // Définissez la variable customerId ici
  String? userName;
  String? userPhone;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _confirmDeletion() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // L'utilisateur doit taper sur les boutons !
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Êtes-vous sûr de vouloir désactiver votre compte ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Non', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();  // Ferme la boîte de dialogue
              },
            ),
            TextButton(
              child: Text('Oui', style: TextStyle(color: Colors.blue)),
              onPressed: () async {
                if (customerId != null) {
                  await deleteAccount(customerId!);
                  _performLogout(context);  // Déconnecter l'utilisateur
                  Navigator.of(context).pop();  // Ferme la boîte de dialogue
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                        (Route<dynamic> route) => false,  // Ceci retirera toutes les routes précédentes
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getKeys());  // Imprimez toutes les clés stockées
    print(prefs.getInt('customerId'));  // Imprimez la valeur de customerId
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      setState(() {
        userEmail = prefs.getString('userEmail');
        customerId = prefs.getInt('customerId');
      });
    }
  }
  Future<void> deleteAccount(int customerId) async {
    final String url = 'http://localhost/presta/api/customers/$customerId?ws_key=HXK91J3162VDCQR8DAZD7Y77PT1Z76WD';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode == 200) {
      print('Compte supprimé avec succès');
    } else {
      print('Erreur lors de la suppression du compte: ${response.statusCode}');
      print('Réponse: ${response.body}');
    }
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(isLoggedIn: isLoggedIn),
      drawer: DrawerContent(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 24),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black, // Arrow icon color
                    size: 25,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Center(
                    child: Text(
                      'Votre compte',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: ClipOval(
                child: Image.asset(
                  'assets/images/profil_vide.jpg',
                  height: 100,
                  width: 100,  // Assurez-vous que la largeur et la hauteur sont les mêmes pour obtenir un cercle parfait
                  fit: BoxFit.cover,  // Ceci garantira que l'image couvre l'espace du cercle sans déformation
                ),
              ),
            ),

            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (customerId != null) {  // Vérifiez que customerId n'est pas null
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(customerId: customerId!),
                    ),
                  );
                } else {
                  // Gérer le cas où customerId est null
                  print('customerId is null');
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,  // Couleur du bouton
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),  // Padding augmenté
                minimumSize: Size(double.infinity, 60),  // Taille minimum spécifiée
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),  // Bords arrondis
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Aligner les enfants aux extrémités opposées
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings, color: Colors.orange),  // Icône d'information
                      SizedBox(width: 8),  // Espacement entre l'icône et le texte
                      Text('Mes informations', style: TextStyle(color: Colors.black)),  // Texte du bouton en noir
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),  // Flèche à droite
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {

              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,  // Couleur du bouton
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),  // Padding augmenté
                minimumSize: Size(double.infinity, 60),  // Taille minimum spécifiée
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),  // Bords arrondis
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Aligner les enfants aux extrémités opposées
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, color: Colors.orange),  // Icône d'historique
                      SizedBox(width: 8),  // Espacement entre l'icône et le texte
                      Text('Historique de mes commandes', style: TextStyle(color: Colors.black)),  // Texte du bouton en noir
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),  // Flèche à droite
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                  _performLogout(context);
              },
              child: Text('Se déconnecter'),
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
                fixedSize: Size(390, 49),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _confirmDeletion();
              },
              child: Text('Désactiver le compte'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red[900],
                fixedSize: Size(390, 49),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),


          ],
        ),
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
void _performLogout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  // Supprimez les valeurs associées à la session de l'utilisateur
  await prefs.remove('userEmail');
  await prefs.remove('isLoggedIn');

  // Naviguez vers la page de connexion et retirez toutes les autres routes
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,  // Ceci retirera toutes les routes précédentes
  );
}
