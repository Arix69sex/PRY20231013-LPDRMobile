import 'package:flutter/material.dart';
import 'package:lpdr_mobile/pages/historyPage.dart';
import 'package:lpdr_mobile/pages/home.dart';
import 'package:lpdr_mobile/pages/loginPage.dart';
import 'package:lpdr_mobile/pages/profilePage.dart';
import 'package:lpdr_mobile/util/Jwt.dart';

class Sidebar extends StatelessWidget {
  Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: MediaQuery.of(context).size.height, // Set your desired width
      child: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Text(
              'Infraction Detection',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.camera),
                  title: Text('Cámara'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Perfil'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Historial'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HistoryPage()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () async {
                    await logout(context);
                  },
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}

Future<void> logout(context) async {
  await Jwt.removeToken();
  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
}
