import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meetingzilla/constants/colors.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/pages/about_page.dart';
import 'package:meetingzilla/pages/login_page.dart';
import 'package:meetingzilla/pages/update_page.dart';
import 'package:meetingzilla/pages/upload_image.dart';
import 'package:meetingzilla/pages/welcome_page.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
import 'package:meetingzilla/repository/firebase_functions.dart';
import 'package:meetingzilla/widgets/custom_app_bar.dart';
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
  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  void _checkEmailVerification() async {
    final emailVerify = await FirebaseFunctions.isEmailVerified();
    setState(() {
      _isEmailVerified = emailVerify;
    });
  }

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
            ),
            Expanded(child: _bottomBodyArea(bodyHeight)),
          ],
        ),
      ),
    );
  }

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

  Container _bottomBodyArea(double height) => Container(
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextArea(
                    title: '${EMAIL.toUpperCase()} :',
                    text: '${_authProvider.userSnapshot.data()[EMAIL]}',
                  ),
                  if (_isEmailVerified)
                    FaIcon(
                      FontAwesomeIcons.checkCircle,
                      color: secondColor,
                      size: 20.0,
                    )
                ],
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
                titleColor: thirdColor,
                icon: Icons.info,
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
                onTap: _logOutUser,
              ),
              CustomSettingButton(
                title: REMOVE_USER,
                titleColor: Colors.redAccent,
                icon: Icons.delete_forever,
                onTap: _removeUserData,
              ),
              CustomSettingButton(
                title: UPDATE,
                titleColor: thirdColor,
                icon: Icons.repeat,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UpdatePage(),
                      ));
                },
              ),
              Divider(color: Theme.of(context).accentColor),
              SizedBox(height: height * 0.2),
            ],
          ),
        ),
      );

  void _logOutUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(USER_DATA);
    await FirebaseFunctions.signOutUser();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  void _removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(USER_DATA);
    await FirebaseFunctions.signOutUser();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => WelcomePage()));
  }
}
