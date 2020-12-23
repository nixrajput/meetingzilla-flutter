import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetingzilla/pages/views/call_view.dart';
import 'package:meetingzilla/pages/views/chat_view.dart';
import 'package:meetingzilla/pages/views/contact_view.dart';
import 'package:meetingzilla/pages/views/settings_view.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: _bottomBodyArea(bodyHeight)),
            _bottomAppBar(),
          ],
        ),
      ),
    );
  }

  PageView _bottomBodyArea(height) => PageView(
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
        margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: Offset(0.0, 0.0),
                blurRadius: 8.0,
              )
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                _bottomTapped(0);
              },
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Icon(
                  _currentIndex == 0 ? Icons.videocam : Icons.videocam_outlined,
                  size: 32.0,
                  color: _currentIndex == 0
                      ? Theme.of(context).accentColor
                      : Colors.grey,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
                _bottomTapped(1);
              },
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Icon(
                  _currentIndex == 1 ? Icons.person : Icons.person_outline,
                  size: 32.0,
                  color: _currentIndex == 1
                      ? Theme.of(context).accentColor
                      : Colors.grey,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                });
                _bottomTapped(2);
              },
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Icon(
                  _currentIndex == 2
                      ? Icons.chat_bubble_outlined
                      : Icons.chat_bubble_outline_outlined,
                  size: 32.0,
                  color: _currentIndex == 2
                      ? Theme.of(context).accentColor
                      : Colors.grey,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 3;
                });
                _bottomTapped(3);
              },
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Icon(
                  _currentIndex == 3 ? Icons.settings : Icons.settings_outlined,
                  size: 32.0,
                  color: _currentIndex == 3
                      ? Theme.of(context).accentColor
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
}
