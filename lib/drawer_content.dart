import 'package:flutter/material.dart';
import 'Aide.dart';
import 'login_page.dart';

class DrawerContent extends StatelessWidget {
  final BuildContext parentContext;

  DrawerContent(this.parentContext);

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
          const ListTile(
            title: Text(
              'MON COMPTE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_2_outlined,
                color: Color.fromRGBO(255, 181, 0, 1)),
            title: Text('Connexion'),
            onTap: _openLoginPage,
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
