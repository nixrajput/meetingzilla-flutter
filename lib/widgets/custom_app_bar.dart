import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final double titleSize;
  final Color titleColor;
  final Widget leading;
  final Widget trailing;
  final Color bgColor;
  final EdgeInsets padding;
  final double elevation;

  const CustomAppBar({
    @required this.title,
    this.titleSize = 32.0,
    this.titleColor,
    this.leading,
    this.trailing,
    this.padding,
    this.bgColor,
    this.elevation = 0.0,
  }) : assert(title != null, 'Title must not be null.');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: bgColor ?? Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: elevation > 0.0
                ? Colors.black.withOpacity(0.15)
                : Colors.transparent,
            offset: Offset(0.0, elevation ?? 0.0),
            blurRadius: elevation ?? 8.0,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Row(
              children: [
                if (leading != null) leading,
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: titleColor ?? Theme.of(context).accentColor,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing
        ],
      ),
    );
  }
}
