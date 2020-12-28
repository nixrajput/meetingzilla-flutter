import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meetingzilla/constants/colors.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/widgets/custom_app_bar.dart';
import 'package:meetingzilla/widgets/custom_icon_btn.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: '',
    packageName: '',
    version: '',
    buildNumber: '',
  );

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
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
              title: ABOUT,
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

  Widget _bottomBodyArea(height) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            _versionArea(),
            _creditsArea(),
            _socialIconLink(),
          ],
        ),
      );

  Widget _versionArea() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 100.0),
          Image.asset(
            LOCAL_ICON_PATH,
            height: 100.0,
            width: 100.0,
            filterQuality: FilterQuality.high,
          ),
          Text(
            _packageInfo.appName ?? 'Loading...',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).accentColor,
            ),
          ),
          Text(
            '${_packageInfo.version ?? '0'} (${_packageInfo.buildNumber ?? '0'})',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ],
      );

  Widget _creditsArea() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Credits',
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: secondColor),
          ),
          SizedBox(height: 10.0),
          Text(
            'Developer : Nikhil Kumar',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            'UI/UX : Nikhil Kumar',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            'App Name : Diwakar Chaubey',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );

  Widget _socialIconLink() => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomIconButton(
            icon: FontAwesomeIcons.facebook,
            onTap: () async {
              final url = 'https://facebook.com/nixrajput07';
              if (await canLaunch(url)) {
                await launch(
                  url,
                  forceSafariVC: true,
                  forceWebView: true,
                  enableJavaScript: true,
                  statusBarBrightness: Brightness.light,
                );
              }
            },
          ),
          CustomIconButton(
            icon: FontAwesomeIcons.twitter,
            onTap: () async {
              final url = 'https://twitter.com/nixrajput07';
              if (await canLaunch(url)) {
                await launch(
                  url,
                  forceSafariVC: true,
                  forceWebView: true,
                  enableJavaScript: true,
                  statusBarBrightness: Brightness.light,
                );
              }
            },
          ),
          CustomIconButton(
            icon: FontAwesomeIcons.instagram,
            onTap: () async {
              final url = 'https://instagram.com/nixrajput';
              if (await canLaunch(url)) {
                await launch(
                  url,
                  forceSafariVC: true,
                  forceWebView: true,
                  enableJavaScript: true,
                  statusBarBrightness: Brightness.light,
                );
              }
            },
          ),
          CustomIconButton(
            icon: FontAwesomeIcons.github,
            onTap: () async {
              final url = 'https://github.com/nixrajput';
              if (await canLaunch(url)) {
                await launch(
                  url,
                  forceSafariVC: true,
                  forceWebView: true,
                  enableJavaScript: true,
                  statusBarBrightness: Brightness.light,
                );
              }
            },
          ),
        ],
      );
}
