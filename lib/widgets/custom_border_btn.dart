import 'package:flutter/material.dart';

class CustomBorderButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final double borderRadius;
  final EdgeInsets padding;
  final Color titleColor;
  final double fontSize;
  final Color borderColor;

  const CustomBorderButton({
    @required this.title,
    this.titleColor,
    @required this.onTap,
    this.borderRadius,
    this.padding,
    this.fontSize,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
    );
  }
}
