import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meetingzilla/constants/colors.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/repository/firebase_functions.dart';
import 'package:meetingzilla/widgets/custom_app_bar.dart';
import 'package:meetingzilla/widgets/custom_circular_progress.dart';
import 'package:meetingzilla/widgets/custom_setting_btn.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

class UpdatePage extends StatefulWidget {
  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
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

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> _checkUpdate() async {
    setState(() {
      _isLoading = true;
    });
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
    _showUpdateDialog();
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

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

  Future<bool> _showUpdateDialog() {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                contentPadding: const EdgeInsets.all(16.0),
                content: Text(
                  !_hasUpdate ? 'No update available.' : UPDATE_WARNING,
                ),
                actionsPadding: const EdgeInsets.all(0.0),
                actions: <Widget>[
                  FlatButton(
                    child: Text("OK"),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () {
                      if (!_hasUpdate) Navigator.pop(ctx);
                    },
                  ),
                ]));
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
                title: CHECK_UPDATE,
                titleColor: thirdColor,
                onTap: _checkUpdate,
                subtitle: _isLoading
                    ? CustomCircularProgressIndicator(
                        color: thirdColor,
                        size: 24.0,
                      )
                    : SizedBox(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Divider(color: Theme.of(context).accentColor),
              ),
              CustomSettingButton(
                title: CHANGELOG,
                titleColor: thirdColor,
                onTap: () {},
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Divider(color: Theme.of(context).accentColor),
              ),
              CustomSettingButton(
                title: VERSION,
                titleColor: thirdColor,
                subtitle: Text(
                  '${_packageInfo.version ?? '0'} (${_packageInfo.buildNumber ?? '0'})',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                onTap: () {},
              ),
              Divider(color: Theme.of(context).accentColor),
            ],
          ),
        ),
      );
}
