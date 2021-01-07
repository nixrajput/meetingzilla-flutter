import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meetingzilla/constants/colors.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/widgets/custom_app_bar.dart';
import 'package:meetingzilla/widgets/custom_icon_btn.dart';
import 'package:meetingzilla/widgets/custom_text_btn.dart';
import 'package:meetingzilla/widgets/custom_text_widget.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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

  Widget _bottomBodyArea(double height) => SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              _versionArea(height),
              SizedBox(height: height * 0.1),
              _companyDetails(height),
              SizedBox(height: height * 0.1),
              _socialIconLink(),
            ],
          ),
        ),
      );

  Widget _versionArea(double height) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: height * 0.1),
          Image.asset(
            LOCAL_ICON_PATH,
            height: 100.0,
          ),
          Text(
            _packageInfo.appName ?? '$LOADING...',
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

  Widget _companyDetails(double height) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$POWERED $BY',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Image.asset(
            COMPANY_ICON_IMAGE_PATH,
            height: height * 0.1,
          ),
          SizedBox(height: height * 0.05),
          CustomTextBtn(
            text: '$CREDITS',
            onTap: () => _showCreditsBottomSheet(context),
          ),
          CustomTextBtn(
            text: '$PRIVACY_POLICY',
            onTap: () => _navigateToUrl(PRIVACY_POLICY_URL),
          ),
          CustomTextBtn(
            text: '$TERMS_CONDITIONS',
          ),
        ],
      );

  void _navigateToUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        enableJavaScript: true,
      ).catchError((err) {
        print(err.toString());
      });
    }
  }

  _showCreditsBottomSheet(BuildContext ctx) => showModalBottomSheet(
        context: ctx,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        ),
        builder: (ctx) => Container(
          margin: const EdgeInsets.only(
            top: 20.0,
            bottom: 20.0,
          ),
          child: _creditsArea(),
        ),
      );

  Widget _creditsArea() => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CREDITS,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: secondColor),
            ),
            SizedBox(height: 10.0),
            CustomTextWidget(
              title: '${LEAD.toUpperCase()} ${DEV.toUpperCase()} :',
              text: '$NIKHIL $KUMAR',
            ),
            CustomTextWidget(
              title: '${UI_UX.toUpperCase()} ${DEV.toUpperCase()} :',
              text: '$NIKHIL $KUMAR',
            ),
            CustomTextWidget(
              title: '${APP.toUpperCase()} ${NAME.toUpperCase()} :',
              text: '$DIWAKAR $CHAUBEY',
            ),
          ],
        ),
      );

  Widget _socialIconLink() => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomIconBtn(
            icon: FontAwesomeIcons.facebook,
            onTap: () => _navigateToUrl(DEV_FACEBOOK_LINK),
          ),
          CustomIconBtn(
            icon: FontAwesomeIcons.twitter,
            onTap: () => _navigateToUrl(DEV_TWITTER_LINK),
          ),
          CustomIconBtn(
            icon: FontAwesomeIcons.instagram,
            onTap: () => _navigateToUrl(DEV_INSTA_LINK),
          ),
          CustomIconBtn(
            icon: FontAwesomeIcons.github,
            onTap: () => _navigateToUrl(DEV_GITHUB_LINK),
          ),
        ],
      );
}
