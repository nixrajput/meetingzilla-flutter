import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/pages/index_page.dart';
import 'package:meetingzilla/pages/login_page.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
import 'package:meetingzilla/repository/firebase_functions.dart';
import 'package:meetingzilla/widgets/custom_circular_progress.dart';
import 'package:meetingzilla/widgets/custom_rounded_btn.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  AuthProvider _authProvider;
  bool _updateAvail = false;
  var _downloadUrl;
  var _latVer;
  List<dynamic> _changelog;
  AnimationController _animationController;
  DocumentSnapshot _appInfoSnapshot;
  PackageInfo _packageInfo;

  @override
  void initState() {
    super.initState();
    _checkAppUpdate();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _authProvider.checkUserInfo();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _animationController.repeat();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void _checkAppUpdate() async {
    await _initPackageInfo();
    _appInfoSnapshot = await FirebaseFunctions.getAppInfo();
    if (_appInfoSnapshot.exists) {
      final ver = _appInfoSnapshot.data()[LATEST_VER];
      int major = int.parse(_packageInfo.version.substring(0, 1));
      int minor = int.parse(_packageInfo.version.substring(2, 3));
      int patch = int.parse(
          _packageInfo.version.substring(4, _packageInfo.version.length));
      print('$VERSION : $major.$minor.$patch');
      final Version currVer = Version(major, minor, patch);
      final Version latVer = Version.parse(ver);

      if (latVer > currVer) {
        setState(() {
          _updateAvail = true;
          _downloadUrl = _appInfoSnapshot.data()[APP_URL].toString();
          _changelog = _appInfoSnapshot.data()[CHANGELOG];
          _latVer = latVer;
        });
      }

      if (!_updateAvail) {
        _navigateToPage();
      }
    } else {
      print("User data doesn't not exists.");
    }
  }

  void _navigateToDownloadUrl() async {
    final url = _downloadUrl;
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        enableJavaScript: true,
        statusBarBrightness: Brightness.light,
      );
    }
  }

  void _navigateToPage() async {
    if (_authProvider.userDataEmpty) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginPage()));
    } else {
      User user = await FirebaseFunctions.getCurrentUser();
      if (user != null) {
        await _authProvider.getUserInfo(user.uid);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => IndexPage()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginPage()));
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      body: Center(
        child: _updateAvail
            ? _updateScreen(bodyHeight)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    '$IMAGE_DIR/icon.png',
                    height: 100.0,
                    width: 100.0,
                    filterQuality: FilterQuality.high,
                  ),
                  SizedBox(height: bodyHeight * 0.1),
                  CustomCircularProgressIndicator(
                    color: Theme.of(context).accentColor,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _updateScreen(bodyHeight) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 16.0,
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(0.0, 0.0),
                      blurRadius: 16.0,
                    ),
                  ]),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '$UPDATE_WARNING',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      '${VERSION.toUpperCase()} : $_latVer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      '${CHANGELOG.toUpperCase()}:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _changelog.length,
                      itemBuilder: (ctx, index) =>
                          Text('• ${_changelog[index]}'),
                    ),
                    SizedBox(height: 40.0),
                    CustomRoundedButton(
                      title: '$UPDATE',
                      onTap: _navigateToDownloadUrl,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}