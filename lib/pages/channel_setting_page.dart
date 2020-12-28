import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/widgets/custom_app_bar.dart';

class ChannelSettingsPage extends StatefulWidget {
  @override
  _ChannelSettingsPageState createState() => _ChannelSettingsPageState();
}

class _ChannelSettingsPageState extends State<ChannelSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final double bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: SETTINGS,
              titleSize: bodyHeight * 0.04,
              titleColor: Theme.of(context).accentColor,
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

  Container _bottomBodyArea(double height) => Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [],
      )));
}
