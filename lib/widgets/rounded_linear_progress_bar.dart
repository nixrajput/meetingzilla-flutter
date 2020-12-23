import 'package:flutter/material.dart';

class RoundedLinearProgressBar extends StatelessWidget {
  final double progress;
  final Animation<Color> color;

  const RoundedLinearProgressBar({Key key, this.progress, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 16.0,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        child: LinearProgressIndicator(
          value: progress,
        ),
      ),
    );
  }
}
