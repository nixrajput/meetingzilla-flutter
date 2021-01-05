import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meetingzilla/constants/colors.dart';
import 'package:meetingzilla/pages/views/call_view.dart';
import 'package:meetingzilla/pages/views/chat_view.dart';
import 'package:meetingzilla/pages/views/contact_view.dart';
import 'package:meetingzilla/pages/views/settings_view.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
import 'package:meetingzilla/widgets/custom_icon_btn.dart';
import 'package:provider/provider.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  final _channelIdController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthProvider _authProvider;

  int _currentIndex = 0;

  PageController _pageController =
      PageController(initialPage: 0, keepPage: true);

  void _pageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _bottomTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage((index),
          duration: Duration(milliseconds: 100), curve: Curves.fastOutSlowIn);
    });
  }

  @override
  void dispose() {
    _channelIdController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

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
        child: Stack(
          children: [
            _createPageView(bodyHeight),
            Align(
              alignment: Alignment.bottomCenter,
              child: _bottomAppBar(),
            ),
          ],
        ),
      ),
    );
  }

  PageView _createPageView(height) => PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _pageChanged(index);
        },
        children: [
          CallView(authProvider: _authProvider),
          ContactView(),
          ChatView(),
          SettingsView(),
        ],
      );

  Widget _bottomAppBar() => Container(
        margin: const EdgeInsets.all(16.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).bottomAppBarColor,
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: Offset(0.0, 2.0),
              blurRadius: 8.0,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomIconBtn(
              padding: const EdgeInsets.all(16.0),
              icon: FontAwesomeIcons.video,
              iconColor: _currentIndex == 0
                  ? Theme.of(context).accentColor
                  : Colors.grey,
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                _bottomTapped(0);
              },
            ),
            CustomIconBtn(
              padding: const EdgeInsets.all(16.0),
              icon: FontAwesomeIcons.calendar,
              iconColor: _currentIndex == 1
                  ? Theme.of(context).accentColor
                  : Colors.grey,
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
                _bottomTapped(1);
              },
            ),
            CustomIconBtn(
              padding: const EdgeInsets.all(16.0),
              icon: FontAwesomeIcons.solidEnvelope,
              iconColor: _currentIndex == 2
                  ? Theme.of(context).accentColor
                  : Colors.grey,
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                });
                _bottomTapped(2);
              },
            ),
            CustomIconBtn(
              padding: const EdgeInsets.all(16.0),
              icon: FontAwesomeIcons.cog,
              iconColor: _currentIndex == 3
                  ? Theme.of(context).accentColor
                  : Colors.grey,
              onTap: () {
                setState(() {
                  _currentIndex = 3;
                });
                _bottomTapped(3);
              },
            ),
          ],
        ),
      );
}
