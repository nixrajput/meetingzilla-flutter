import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/pages/index_page.dart';
import 'package:meetingzilla/pages/login_page.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
import 'package:meetingzilla/repository/firebase_functions.dart';
import 'package:meetingzilla/widgets/custom_circular_progress.dart';
import 'package:meetingzilla/widgets/custom_rounded_btn.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  AuthProvider _authProvider;
  bool _hasUpdate = false;
  bool _hasError = false;
  bool _isLoading = false;
  var _message;
  var _downloadUrl;
  var _latVer;
  List<dynamic> _changelog;
  PackageInfo _packageInfo = PackageInfo(
    appName: UNKNOWN,
    packageName: UNKNOWN,
    version: UNKNOWN,
    buildNumber: UNKNOWN,
  );

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _authProvider.checkUserInfo();
  }

  Future<void> _initializeApp() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = packageInfo;
      });
    } on Exception catch (e) {
      setState(() {
        _hasError = true;
        _message = e.toString();
        _isLoading = false;
      });
    }
    try {
      await FirebaseFunctions.getAppInfo().then((appInfoSnapshot) {
        if (appInfoSnapshot.exists) {
          final ver = appInfoSnapshot.data()[LATEST_VER];
          int major = int.parse(_packageInfo.version.substring(0, 1));
          int minor = int.parse(_packageInfo.version.substring(2, 3));
          int patch = int.parse(
              _packageInfo.version.substring(4, _packageInfo.version.length));
          print('$VERSION : $major.$minor.$patch');
          print('LATEST $VERSION: $ver');
          final Version currVer = Version(major, minor, patch);
          final Version latVer = Version.parse(ver);

          if (latVer > currVer) {
            setState(() {
              _hasUpdate = true;
              _downloadUrl = appInfoSnapshot.data()[APP_URL].toString();
              _changelog = appInfoSnapshot.data()[CHANGELOG];
              _latVer = latVer;
            });
          }
          if (!_hasUpdate && !_isLoading && !_hasError) {
            _navigateToPage();
          }
        } else {
          setState(() {
            _hasError = true;
            _message = "User data doesn't not exists.";
            _isLoading = false;
          });
        }
      });
    } on Exception catch (ex) {
      setState(() {
        _hasError = true;
        _message = ex.toString();
        _isLoading = false;
      });
    }
    setState(() {
      _isLoading = false;
    });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
        body: Center(
      child: _isLoading
          ? _loadingScreen(bodyHeight)
          : _hasError
              ? _errorScreen()
              : _hasUpdate
                  ? _updateScreen(bodyHeight)
                  : _loadingScreen(bodyHeight),
    ));
  }

  Widget _errorScreen() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 40.0),
            CustomRoundedButton(
              title: '$RETRY',
              onTap: _initializeApp,
            ),
          ],
        ),
      );

  Widget _loadingScreen(bodyHeight) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            LOCAL_ICON_PATH,
            height: 100.0,
            width: 100.0,
            filterQuality: FilterQuality.high,
          ),
          SizedBox(height: bodyHeight * 0.1),
          CustomCircularProgressIndicator(
            color: Theme.of(context).accentColor,
          ),
        ],
      );

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
