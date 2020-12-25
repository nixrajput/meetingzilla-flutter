import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meetingzilla/constants/colors.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/widgets/custom_app_bar.dart';
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
            CustomAppBar(
              title: UPDATE,
              trailing: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: FaIcon(
                  FontAwesomeIcons.solidArrowAltCircleLeft,
                  color: Theme.of(context).accentColor,
                  size: 32.0,
                ),
              ),
            ),
            Expanded(child: _bottomBodyArea(bodyHeight)),
          ],
        ),
      ),
    );
  }

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
                titleColor: thirdColor,
                onTap: () {},
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Divider(color: Theme.of(context).accentColor),
              ),
              CustomSettingButton(
                title: 'Changelog',
                titleColor: thirdColor,
                onTap: () {},
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Divider(color: Theme.of(context).accentColor),
              ),
              CustomSettingButton(
                title: 'Version',
                titleColor: thirdColor,
                onTap: () {},
              ),
              Divider(color: Theme.of(context).accentColor),
            ],
          ),
        ),
      );
}
