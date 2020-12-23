import 'package:flutter/material.dart';

class BottomBarButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final double iconSize;
  final double margin;
  final double padding;

  const BottomBarButton({
    this.onTap,
    this.color = Colors.transparent,
    this.icon,
    this.iconColor,
    this.borderColor = Colors.white,
    this.iconSize = 24.0,
    this.margin = 0.0,
    this.padding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        margin: EdgeInsets.all(margin),
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border(
              top: BorderSide(color: borderColor),
              bottom: BorderSide(color: borderColor),
              left: BorderSide(color: borderColor),
              right: BorderSide(color: borderColor),
            )),
        child: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }
}
