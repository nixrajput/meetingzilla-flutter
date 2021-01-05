import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetingzilla/constants/colors.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/pages/index_page.dart';
import 'package:meetingzilla/pages/login_page.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
import 'package:meetingzilla/repository/firebase_functions.dart';
import 'package:meetingzilla/widgets/custom_border_btn.dart';
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
  bool _hasUpdate = false;
  bool _hasError = false;
  bool _isLoading = false;
  var _message;
  var _downloadUrl;
  var _latVer;
  var _latBuildNo;
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
    setState(() {
      _isLoading = true;
    });
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = packageInfo;
      });

      try {
        await FirebaseFunctions.getAppInfo().then((appInfoSnapshot) {
          if (appInfoSnapshot.exists) {
            final String latVer = appInfoSnapshot.data()[LATEST_VER];
            final int latBuildNo =
                appInfoSnapshot.data()['latest_build_number'];
            int major = int.parse(_packageInfo.version.substring(0, 1));
            int minor = int.parse(_packageInfo.version.substring(2, 3));
            int patch = int.parse(
                _packageInfo.version.substring(4, _packageInfo.version.length));
            int currBuildNo = int.parse(_packageInfo.buildNumber);
            print('$VERSION : $major.$minor.$patch');
            print('LATEST $VERSION: $latVer');
            final Version currVer = Version(major, minor, patch);
            final Version latVersion = Version.parse(latVer);

            if (latVersion > currVer || latBuildNo > currBuildNo) {
              setState(() {
                _hasUpdate = true;
                _hasError = false;
                _downloadUrl = appInfoSnapshot.data()[APP_URL].toString();
                _changelog = appInfoSnapshot.data()[CHANGELOG.toLowerCase()];
                _latVer = latVersion;
                _latBuildNo = latBuildNo;
              });
            } else {
              setState(() {
                _hasUpdate = false;
                _hasError = false;
              });
            }
          } else {
            setState(() {
              _hasError = true;
              _message = "App information doesn't exists.";
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
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      setState(() {
        _hasError = true;
        _message = e.toString();
        _isLoading = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    if (!_hasUpdate && !_isLoading && !_hasError) {
      _navigateToPage();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    final double bodyWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Center(
      child: _buildBody(bodyWidth, bodyHeight),
    ));
  }

  Widget _buildBody(double width, double height) {
    if (_isLoading && !_hasError && !_hasUpdate) {
      return _loadingScreen(width, height);
    }
    if (_hasError && !_hasUpdate && !_isLoading) {
      return _errorScreen(width, height);
    }
    if (_hasUpdate && !_hasError && !_isLoading) {
      return _updateScreen(height);
    }
    return _loadingScreen(width, height);
  }

  Widget _errorScreen(double width, double height) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              ERROR_IMAGE_PATH,
              width: width * 0.5,
            ),
            SizedBox(height: 40.0),
            Text(
              "An Error Occurred!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_message != null) SizedBox(height: 40.0),
            if (_message != null)
              Text(
                _message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            SizedBox(height: 40.0),
            CustomBorderBtn(
              width: width * 0.25,
              padding: EdgeInsets.symmetric(vertical: 8.0),
              title: '$RETRY',
              onTap: _initializeApp,
            )
          ],
        ),
      );

  Widget _loadingScreen(double width, double height) => Container(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: height * 0.1),
                Image.asset(
                  LOCAL_ICON_PATH,
                  height: 64.0,
                ),
                Text(
                  '$APP_NAME',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomCircularProgressIndicator(
                  color: Theme.of(context).accentColor,
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Powered by',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Image.asset(
                  COMPANY_ICON_IMAGE_PATH,
                  height: 80.0,
                ),
              ],
            ),
          ],
        ),
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
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      '${VERSION.toUpperCase()} : $_latVer ($_latBuildNo)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(color: thirdColor),
                    Text(
                      '${CHANGELOG.toUpperCase()}:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: secondColor,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _changelog.length,
                      itemBuilder: (ctx, index) => Text(
                        '• ${_changelog[index]}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.0),
                    CustomRoundedBtn(
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
