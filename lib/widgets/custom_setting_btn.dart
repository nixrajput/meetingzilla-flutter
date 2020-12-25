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
    this.titleColor,
    this.iconColor,
    this.arrowColor,
    this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 10.0,
        ),
        color: bgColor ?? Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    color: titleColor ?? iconColor,
                  ),
                if (icon != null) SizedBox(width: 20.0),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: titleColor ?? arrowColor,
            ),
          ],
        ),
      ),
    );
  }
}
