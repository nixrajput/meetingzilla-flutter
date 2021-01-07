import 'package:flutter/material.dart';
import 'package:meetingzilla/constants/colors.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/pages/about_page.dart';
import 'package:meetingzilla/pages/login_page.dart';
import 'package:meetingzilla/pages/update_page.dart';
import 'package:meetingzilla/pages/upload_image_page.dart';
import 'package:meetingzilla/pages/welcome_page.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
import 'package:meetingzilla/repository/firebase_functions.dart';
import 'package:meetingzilla/widgets/custom_app_bar.dart';
import 'package:meetingzilla/widgets/custom_setting_btn.dart';
import 'package:meetingzilla/widgets/custom_text_widget.dart';
import 'package:meetingzilla/widgets/rounded_network_image.dart';
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
            ),
            Expanded(child: _bottomBodyArea(bodyHeight)),
          ],
        ),
      ),
    );
  }

  Widget _imageArea(String _imageUrl) {
    if (_imageUrl != null) {
      return CircleAvatar(
        radius: 100.0,
        backgroundColor: Colors.transparent,
        child: RoundedNetworkImage(
          imageSize: 200.0,
          imageUrl: _imageUrl,
          strokeWidth: 2.0,
          strokeColor: Theme.of(context).accentColor,
        ),
      );
    }
    return CircleAvatar(
      radius: 100.0,
      backgroundColor: Colors.grey[550],
      child: Text(
        "Add Image",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }

  Container _bottomBodyArea(double height) => Container(
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
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '${_authProvider.userSnapshot.data()[NAME]}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.subtitle1.color,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              Divider(color: Theme.of(context).accentColor),
              SizedBox(height: 10.0),
              CustomTextWidget(
                title: '${EMAIL.toUpperCase()} :',
                text: '${_authProvider.userSnapshot.data()[EMAIL]}',
              ),
              CustomTextWidget(
                title: '${UID.toUpperCase()} :',
                text: '${_authProvider.userSnapshot.data()[USER_ID]}',
              ),
              CustomTextWidget(
                title: '${MEETING_ID.toUpperCase()} :',
                text: '${_authProvider.userSnapshot.data()[CHANNEL_ID]}',
              ),
              SizedBox(height: 10.0),
              Divider(color: Theme.of(context).accentColor),
              CustomSettingBtn(
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
              CustomSettingBtn(
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
              CustomSettingBtn(
                title: LOGOUT,
                titleColor: Colors.redAccent,
                icon: Icons.logout,
                onTap: _logOutUser,
              ),
              CustomSettingBtn(
                title: REMOVE_USER,
                titleColor: Colors.redAccent,
                icon: Icons.delete_forever,
                onTap: _removeUserData,
              ),
              Divider(color: Theme.of(context).accentColor),
              SizedBox(height: height * 0.15),
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
