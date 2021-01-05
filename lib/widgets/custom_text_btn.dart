import 'package:flutter/material.dart';
import 'package:meetingzilla/constants/colors.dart';

class CustomTextBtn extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color bgColor;
  final double fontSize;
  final EdgeInsets padding;
  final VoidCallback onTap;

  const CustomTextBtn({
    this.text,
    this.textColor,
    this.bgColor,
    this.fontSize,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: bgColor ?? Colors.transparent,
        padding: padding ?? const EdgeInsets.all(8.0),
        child: Text(
          text ?? "null",
          style: TextStyle(
              fontSize: fontSize ?? 18.0,
              fontWeight: FontWeight.bold,
              color: textColor ?? secondColor),
        ),
      ),
    );
  }
}
