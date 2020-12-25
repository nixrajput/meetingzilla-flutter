import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    this.color,
    this.icon,
    this.iconColor,
    this.borderColor,
    this.iconSize,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding ?? 8.0),
        margin: EdgeInsets.all(margin ?? 0.0),
        decoration: BoxDecoration(
            color: color ?? Colors.transparent,
            shape: BoxShape.circle,
            border: Border(
              top: BorderSide(color: borderColor ?? Colors.white),
              bottom: BorderSide(color: borderColor ?? Colors.white),
              left: BorderSide(color: borderColor ?? Colors.white),
              right: BorderSide(color: borderColor ?? Colors.white),
            )),
        child: FaIcon(
          icon,
          color: iconColor ?? Colors.white,
          size: iconSize ?? 24.0,
        ),
      ),
    );
  }
}
