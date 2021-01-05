import 'package:flutter/material.dart';

class CustomBorderBtn extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final double borderRadius;
  final EdgeInsets padding;
  final Color titleColor;
  final double fontSize;
  final Color borderColor;
  final double width;

  const CustomBorderBtn({
    @required this.title,
    this.titleColor,
    @required this.onTap,
    this.borderRadius,
    this.padding,
    this.fontSize,
    this.borderColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        padding: padding ?? const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 16.0)),
          border: Border(
            top: BorderSide(
              color: borderColor ?? Theme.of(context).accentColor,
            ),
            bottom: BorderSide(
              color: borderColor ?? Theme.of(context).accentColor,
            ),
            left: BorderSide(
              color: borderColor ?? Theme.of(context).accentColor,
            ),
            right: BorderSide(
              color: borderColor ?? Theme.of(context).accentColor,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: titleColor ?? Theme.of(context).accentColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize ?? 18.0,
          ),
        ),
      ),
    );
  }
}
