import 'package:flutter/material.dart';
import 'package:meetingzilla/constants/colors.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/widgets/custom_setting_btn.dart';

class UpdatePage extends StatefulWidget {
  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  @override
  Widget build(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _topBodyArea(bodyHeight),
            Expanded(child: _bottomBodyArea(bodyHeight)),
          ],
        ),
      ),
    );
  }

  Container _topBodyArea(height) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              UPDATE,
              style: TextStyle(
                fontSize: height * 0.04,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).accentColor,
              ),
            ),
          ],
        ),
      );

  Container _bottomBodyArea(height) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Divider(color: Theme.of(context).accentColor),
              CustomSettingButton(
                title: 'Check For Update',
                titleColor: secondColor,
                onTap: () {},
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Divider(color: Theme.of(context).accentColor),
              ),
              CustomSettingButton(
                title: 'Changelog',
                titleColor: Colors.redAccent,
                onTap: () {},
              ),
              Divider(color: Theme.of(context).accentColor),
            ],
          ),
        ),
      );
}
