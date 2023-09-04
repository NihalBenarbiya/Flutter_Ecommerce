import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Aide.dart';
import 'ConditionVente.dart';
import 'login_page.dart';

class DrawerContent extends StatelessWidget {
  final BuildContext parentContext;
  final bool? isLoggedIn; // Rendre le paramètre facultatif en utilisant {}


  DrawerContent(this.parentContext, {this.isLoggedIn});
  Future<String?> _getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    print('User Email: $userEmail');
    return userEmail;
  }

  Future<bool> _getIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false; // Utilisez false par défaut si la valeur n'est pas définie
  }

  void _openAidePage() {
    Navigator.pop(parentContext);
    Navigator.push(
        parentContext, MaterialPageRoute(builder: (context) => AideWidget()));
  }

  void _openLoginPage() {
    Navigator.pop(parentContext);
    Navigator.push(
        parentContext, MaterialPageRoute(builder: (context) => LoginPage()));
  }
  void _openConditionPage() {
    Navigator.pop(parentContext);
    Navigator.push(
        parentContext, MaterialPageRoute(builder: (context) => ConditionVente()));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      child: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
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
          FutureBuilder<bool>(
            future: _getIsLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final isLoggedIn = snapshot.data;
                if (isLoggedIn!) {
                  return FutureBuilder<String?>(
                    future: _getUserEmail(),
                    builder: (context, emailSnapshot) {
                      if (emailSnapshot.connectionState ==
                          ConnectionState.done) {
                        final userEmail = emailSnapshot.data;
                        return UserAccountsDrawerHeader(
                          accountName: null, // Mettez ici le nom de l'utilisateur s'il est disponible
                          accountEmail: FutureBuilder<String?>(
                            future: _getUserEmail(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                final userEmail = snapshot.data;
                                return Text('E-mail: $userEmail', style: TextStyle(color: Colors.white));
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                          currentAccountPicture: CircleAvatar(
                            child: Icon(
                              Icons.person, // Icône de profil (par exemple, un visage d'utilisateur)
                              color: Colors.white, // Couleur de l'icône de profil
                            ),
                            backgroundColor: Colors.grey, // Couleur de l'arrière-plan du cercle de profil

                          ),
                      decoration: BoxDecoration(
                      color: const Color.fromRGBO(59, 59, 59, 1), // Couleur de fond de l'en-tête du tiroir
                        )
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  );
                } else {
                  return ListTile(
                    leading: const Icon(
                        Icons.person_2_outlined,
                        color: Color.fromRGBO(255, 181, 0, 1)),
                    title: Text('Connexion'),
                    onTap: _openLoginPage,
                  );
                }
              } else {
                return CircularProgressIndicator();
              }
            },
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
            onTap: _openAidePage,
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet_outlined,
                color: Color.fromRGBO(255, 181, 0, 1)),
            title: Text('Conditions générales de vente'),
            onTap: _openConditionPage,
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
            leading:
            Icon(Icons.info_outline, color: Color.fromRGBO(255, 181, 0, 1)),
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
          FutureBuilder<bool>(
            future: _getIsLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final isLoggedIn = snapshot.data;
                if (isLoggedIn!) {
                  return ListTile(
                    leading: Icon(Icons.logout, color: Color.fromRGBO(255, 181, 0, 1)),
                    title: Text('Déconnexion'),
                    onTap: () {
                      _performLogout(context);
                    },
                  );
                } else {
                  // Si l'utilisateur n'est pas connecté, retournez simplement un conteneur vide.
                  return Container();
                }
              } else {
                // Pendant le chargement, retournez également un conteneur vide.
                return Container();
              }
            },
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
    );
  }
}
void _performLogout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  // Supprimez les valeurs associées à la session de l'utilisateur
  await prefs.remove('userEmail');
  await prefs.remove('isLoggedIn');

  // Naviguez vers la page de connexion
  Navigator.pop(context); // Fermer le tiroir
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}

