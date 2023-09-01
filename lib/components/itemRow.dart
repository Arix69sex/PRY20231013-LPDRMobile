import 'package:flutter/material.dart';

class ItemRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final double textSize;

  ItemRow({
    required this.icon,
    required this.text,
    this.textSize = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 32, color: Colors.grey.shade800), // Name icon
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: textSize),
          ),
        ),
      ],
    );
  }
}
