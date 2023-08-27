import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onMenuPressed;

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
        
        children: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.black, // Icon color
              size: 32.0,
            ),
            onPressed: onMenuPressed,
          ),
          SizedBox(width: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 25, // Adjust the font size as needed
              color: Colors.black, // Text color// FontWeight
            ),
          ),
          SizedBox(width: 48.0), // Spacer for better alignment
        ],
      ),
    );
  }
}
