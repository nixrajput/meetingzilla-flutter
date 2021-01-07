import 'package:flutter/material.dart';

class CustomTextWidget extends StatelessWidget {
  final String title;
  final String text;
  final EdgeInsets padding;
  final Color bgColor;
  final Color titleColor;
  final Color textColor;
  final double titleSize;
  final double textSize;

  const CustomTextWidget({
    this.title,
    this.text,
    this.padding,
    this.bgColor,
    this.titleColor,
    this.textColor,
    this.titleSize,
    this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor ?? Colors.transparent,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null && title.isNotEmpty)
            Text(
              title,
              style: TextStyle(
                color:
                    titleColor ?? Theme.of(context).textTheme.subtitle1.color,
                fontSize: titleSize ?? 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          SizedBox(width: 4.0),
          if (text != null && text.isNotEmpty)
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color:
                      textColor ?? Theme.of(context).textTheme.subtitle1.color,
                  fontSize: textSize ?? 16.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
