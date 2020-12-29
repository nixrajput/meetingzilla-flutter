import 'package:flutter/material.dart';

class CustomSettingButton extends StatelessWidget {
  final String title;
  final Color titleColor;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color arrowColor;
  final VoidCallback onTap;
  final Widget subtitle;

  const CustomSettingButton({
    this.title,
    this.icon,
    this.onTap,
    this.titleColor,
    this.iconColor,
    this.arrowColor,
    this.bgColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: bgColor ?? Theme.of(context).scaffoldBackgroundColor,
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
                    fontWeight: FontWeight.w600,
                    color: titleColor ??
                        Theme.of(context).textTheme.subtitle1.color,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null) subtitle,
                SizedBox(width: 10.0),
                Icon(
                  Icons.arrow_forward_ios,
                  color: titleColor ?? arrowColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
