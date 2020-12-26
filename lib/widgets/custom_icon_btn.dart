import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color titleColor;
  final Color iconColor;
  final Color borderColor;
  final VoidCallback onTap;

  const CustomIconButton({
    @required this.icon,
    this.title,
    this.onTap,
    this.titleColor,
    this.iconColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border(
              top: BorderSide(
                  color: borderColor ?? Theme.of(context).accentColor),
              bottom: BorderSide(
                  color: borderColor ?? Theme.of(context).accentColor),
              left: BorderSide(
                  color: borderColor ?? Theme.of(context).accentColor),
              right: BorderSide(
                  color: borderColor ?? Theme.of(context).accentColor),
            )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              FaIcon(
                icon,
                color: iconColor ?? Theme.of(context).accentColor,
              ),
            if (title != null && title.isNotEmpty)
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: titleColor ?? Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )
          ],
        ),
      ),
    );
  }
}
