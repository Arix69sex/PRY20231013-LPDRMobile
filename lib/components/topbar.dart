import 'package:flutter/material.dart';
import 'package:lpdr_mobile/pages/historyPage.dart';
import 'package:lpdr_mobile/pages/home.dart';
import 'package:lpdr_mobile/pages/profilePage.dart';
import 'package:lpdr_mobile/pages/InfractionsPage.dart';

class TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onMenuPressed;
  final Color accentColor = Color.fromRGBO(241, 75, 80, 1);
  TopBar({required this.title, required this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0, // Set the desired height for the top bar
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Ensure even spacing
        children: [
          Container(
            child: Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.photo_camera_outlined,
                    color: title == "Cámara"
                        ? accentColor
                        : Colors.black, // Icon color
                    size: 40.0,
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
                Text("Cámara",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: title == "Cámara" ? accentColor : Colors.black,
                    ))
              ],
            ),
          ),
          Spacer(),
          Container(
            child: Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.article_outlined,
                    color: title == "Historial"
                        ? accentColor
                        : Colors.black, // Icon color
                    size: 40.0,
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HistoryPage()));
                  },
                ),
                Text("Historial",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: title == "Historial" ? accentColor : Colors.black,
                    ))
              ],
            ),
          ),
          Spacer(),
          Container(
            child: Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.account_circle_outlined,
                    color: title == "Mi perfil"
                        ? accentColor
                        : Colors.black, // Icon color
                    size: 40.0,
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                ),
                Text("Mi perfil",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: title == "Mi perfil" ? accentColor : Colors.black,
                    ))
              ],
            ),
          ), // Spacer for better alignment
        ],
      ),
    );
  }
}
