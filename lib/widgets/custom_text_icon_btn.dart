import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomTextIconButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color titleColor;
  final Color iconColor;
  final Color borderColor;
  final VoidCallback onTap;

  const CustomTextIconButton({
    @required this.icon,
    this.title,
    this.onTap,
    this.titleColor,
    this.iconColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final bodyWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        width: bodyWidth / 3,
        margin: const EdgeInsets.only(
          top: 8.0,
          bottom: 8.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
              child: FaIcon(
                icon,
                color: iconColor ?? Theme.of(context).accentColor,
              ),
            ),
            if (title != null && title.isNotEmpty) SizedBox(height: 4.0),
            if (title != null && title.isNotEmpty)
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: titleColor ?? iconColor,
                  fontWeight: FontWeight.bold,
                ),
              )
          ],
        ),
      ),
    );
  }
}
