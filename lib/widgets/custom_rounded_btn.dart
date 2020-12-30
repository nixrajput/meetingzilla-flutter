import 'package:flutter/material.dart';
import 'package:meetingzilla/constants/colors.dart';

class CustomRoundedButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final double borderRadius;
  final EdgeInsets padding;
  final Color titleColor;
  final double fontSize;
  final Color startColor;
  final Color endColor;

  const CustomRoundedButton({
    @required this.title,
    @required this.onTap,
    this.borderRadius,
    this.padding,
    this.titleColor,
    this.fontSize,
    this.startColor,
    this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 16.0)),
          gradient: LinearGradient(
            colors: [
              startColor ?? firstColor,
              endColor ?? secondColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: titleColor ?? Theme.of(context).scaffoldBackgroundColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize ?? 18.0,
          ),
        ),
      ),
    );
  }
}
