import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meetingzilla/constants/colors.dart';

class CustomGridButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color bgColor;
  final VoidCallback onTap;
  final double padding;
  final double margin;

  const CustomGridButton({
    this.icon,
    this.title,
    this.onTap,
    this.bgColor,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final double bodyWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(margin ?? 8.0),
        padding: EdgeInsets.all(padding ?? 16.0),
        width: (bodyWidth / 2) - 24.0,
        height: (bodyWidth / 2) - 24.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: bgColor ?? Theme.of(context).bottomAppBarColor,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: Offset(0.0, 0.0),
                blurRadius: 8.0,
              )
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 32.0,
            ),
            SizedBox(height: 4.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
