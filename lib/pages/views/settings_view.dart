import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:meetingzilla/constants/colors.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/pages/about.dart';
import 'package:meetingzilla/pages/login.dart';
import 'package:meetingzilla/pages/update_page.dart';
import 'package:meetingzilla/pages/upload_image.dart';
import 'package:meetingzilla/pages/welcome.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
import 'package:meetingzilla/repository/firebase_functions.dart';
import 'package:meetingzilla/widgets/custom_setting_btn.dart';
import 'package:meetingzilla/widgets/rounded_network_image.dart';
import 'package:meetingzilla/widgets/setting_custom_text.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

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
              SETTINGS,
              style: TextStyle(
                fontSize: height * 0.04,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).accentColor,
              ),
            ),
          ],
        ),
      );

  Widget _imageArea(String _imageUrl) {
    if (_imageUrl != null) {
      return AvatarGlow(
        startDelay: Duration(milliseconds: 1000),
        glowColor: Colors.grey.shade900,
        endRadius: 120.0,
        duration: Duration(milliseconds: 2000),
        repeat: true,
        repeatPauseDuration: Duration(milliseconds: 5000),
        shape: BoxShape.circle,
        animate: true,
        curve: Curves.fastOutSlowIn,
        child: CircleAvatar(
          radius: 100.0,
          backgroundColor: Colors.transparent,
          child: RoundedNetworkImage(
            imageSize: 200.0,
            imageUrl: _imageUrl,
            strokeWidth: 0.0,
            strokeColor: Colors.transparent,
          ),
        ),
      );
    }
    return AvatarGlow(
      startDelay: Duration(milliseconds: 1000),
      glowColor: Colors.grey.shade900,
      endRadius: 120.0,
      duration: Duration(milliseconds: 2000),
      repeat: true,
      repeatPauseDuration: Duration(milliseconds: 5000),
      shape: BoxShape.circle,
      animate: true,
      curve: Curves.fastOutSlowIn,
      child: CircleAvatar(
        radius: 100.0,
        backgroundColor: Colors.grey.shade300,
        child: Text(
          "Add Image",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Theme.of(context).accentColor,
          ),
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => UploadImagePage(
                              userId: _authProvider.userSnapshot.data()[UID])));
                },
                child: _imageArea(_authProvider.userSnapshot.data()[IMAGE_URL]),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '${_authProvider.userSnapshot.data()[NAME]}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Divider(color: Theme.of(context).accentColor),
              SizedBox(height: 10.0),
              CustomTextArea(
                title: '${EMAIL.toUpperCase()} :',
                text: '${_authProvider.userSnapshot.data()[EMAIL]}',
              ),
              CustomTextArea(
                title: '${UID.toUpperCase()} :',
                text: '${_authProvider.userSnapshot.data()[USER_ID]}',
              ),
              CustomTextArea(
                title: '${MEETING_ID.toUpperCase()} :',
                text: '${_authProvider.userSnapshot.data()[CHANNEL_ID]}',
              ),
              SizedBox(height: 10.0),
              Divider(color: Theme.of(context).accentColor),
              CustomSettingButton(
                title: ABOUT,
                titleColor: secondColor,
                icon: Icons.info,
                iconColor: secondColor,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AboutPage(),
                      ));
                },
              ),
              CustomSettingButton(
                title: LOGOUT,
                titleColor: Colors.redAccent,
                icon: Icons.logout,
                iconColor: Colors.redAccent,
                onTap: _logOutUser,
              ),
              CustomSettingButton(
                title: REMOVE_USER,
                titleColor: Colors.redAccent,
                icon: Icons.delete_forever,
                iconColor: Colors.redAccent,
                onTap: _removeUserData,
              ),
              CustomSettingButton(
                title: UPDATE,
                titleColor: Theme.of(context).accentColor,
                icon: Icons.repeat,
                iconColor: Theme.of(context).accentColor,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UpdatePage(),
                      ));
                },
              ),
              Divider(color: Theme.of(context).accentColor),
            ],
          ),
        ),
      );

  void _logOutUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(USER_DATA);
    await FirebaseFunctions.signoutUser();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  void _removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(USER_DATA);
    await FirebaseFunctions.signoutUser();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => WelcomePage()));
  }
}
