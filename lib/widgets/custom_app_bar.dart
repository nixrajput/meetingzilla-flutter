import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final double titleSize;
  final Color titleColor;
  final Widget leading;
  final Widget trailing;

  const CustomAppBar({
    @required this.title,
    this.titleSize = 32.0,
    this.titleColor,
    this.leading,
    this.trailing,
  }) : assert(title != null, 'Title must not be null.');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 8.0,
        right: 8.0,
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
