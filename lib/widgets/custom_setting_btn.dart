import 'package:flutter/material.dart';

class CustomSettingButton extends StatelessWidget {
  final String title;
  final Color titleColor;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color arrowColor;
  final VoidCallback onTap;

  const CustomSettingButton({
    Key key,
    this.title,
    this.icon,
    this.onTap,
    this.titleColor = Colors.black,
    this.iconColor = Colors.black,
    this.arrowColor = Colors.black,
    this.bgColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: bgColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    color: iconColor,
                  ),
                if (icon != null) SizedBox(width: 20.0),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: arrowColor,
            ),
          ],
        ),
      ),
    );
  }
}
