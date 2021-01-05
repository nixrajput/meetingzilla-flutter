import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meetingzilla/constants/colors.dart';

class CustomIconBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final double iconSize;
  final Color bgColor;

  const CustomIconBtn({
    this.icon,
    this.iconColor,
    this.onTap,
    this.padding,
    this.iconSize,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: bgColor ?? Colors.transparent,
        padding: padding ?? const EdgeInsets.all(8.0),
        child: FaIcon(
          icon,
          color: iconColor ?? thirdColor,
          size: iconSize ?? 24.0,
        ),
      ),
    );
  }
}
