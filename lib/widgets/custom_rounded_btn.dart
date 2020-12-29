import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetingzilla/constants/colors.dart';

class CustomRoundedButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CustomRoundedButton({@required this.title, @required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.zero,
            topRight: Radius.circular(16.0),
            bottomLeft: Radius.circular(16.0),
            bottomRight: Radius.zero,
          ),
          gradient: LinearGradient(
            colors: [
              firstColor,
              secondColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}
