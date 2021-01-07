import 'package:flutter/material.dart';

class CustomSettingWidget extends StatelessWidget {
  final Widget leading;
  final Widget trailing;
  final Color bgColor;
  final EdgeInsets padding;

  const CustomSettingWidget(
      {this.leading, this.trailing, this.bgColor, this.padding})
      : assert(leading != null, "Leading Widget can't be null."),
        assert(trailing != null, "Trailing Widget can't be null.");

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor ?? Colors.transparent,
      padding: padding ?? const EdgeInsets.all(0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (leading != null) leading,
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
