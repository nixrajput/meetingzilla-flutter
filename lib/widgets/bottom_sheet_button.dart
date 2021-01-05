import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomSheetBtn extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function onTap;

  const BottomSheetBtn({
    this.title,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            FaIcon(
              icon,
              color: Colors.grey,
            ),
            SizedBox(width: 20.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
