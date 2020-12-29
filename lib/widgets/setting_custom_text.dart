import 'package:flutter/material.dart';

class CustomTextArea extends StatelessWidget {
  final String title;
  final String text;
  final bool centerText;

  const CustomTextArea({this.title, this.text, this.centerText = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      // color: Colors.black.withOpacity(0.1),
      child: Row(
        mainAxisAlignment:
            centerText ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8.0),
          Text(
            text,
            style: TextStyle(fontSize: 20.0),
          ),
        ],
      ),
    );
  }
}
