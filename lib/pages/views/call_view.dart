import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meetingzilla/constants/colors.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/pages/join_meeting_page.dart';
import 'package:meetingzilla/pages/start_meeting.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
import 'package:meetingzilla/utils/util_functions.dart';
import 'package:meetingzilla/widgets/custom_app_bar.dart';
import 'package:meetingzilla/widgets/custom_grid_btn.dart';

class CallView extends StatefulWidget {
  final AuthProvider authProvider;

  const CallView({Key key, @required this.authProvider}) : super(key: key);

  @override
  _CallViewState createState() => _CallViewState();
}

class _CallViewState extends State<CallView> {
  @override
  Widget build(BuildContext context) {
    final double bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomAppBar(
            title: APP_NAME,
            titleSize: bodyHeight * 0.04,
            titleColor: Theme.of(context).accentColor,
          ),
          _body(bodyHeight),
        ],
      ),
    );
  }

  Widget _body(double height) => Expanded(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: height * 0.04),
                _meetingIdText(),
                SizedBox(height: height * 0.05),
                _createButtons(),
                SizedBox(height: height * 0.15),
              ],
            ),
          ),
        ),
      );

  Widget _meetingIdText() => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              PID_IS,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0),
            GestureDetector(
              onLongPress: () {
                print(widget.authProvider.meetingId);
                Fluttertoast.showToast(
                  msg: "Meeting ID Copied to clipboard.",
                  gravity: ToastGravity.SNACKBAR,
                );
              },
              child: Text(
                "${formatMeetingId(widget.authProvider.meetingId)}",
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: secondColor,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _createButtons() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomGridButton(
                  icon: FontAwesomeIcons.video,
                  title: START_MEETING,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => StartMeetingPage(
                                  authProvider: widget.authProvider,
                                )));
                    // _createChannel(_authProvider.channelId);
                  },
                ),
                CustomGridButton(
                  icon: FontAwesomeIcons.users,
                  //bgColor: Colors.indigo,
                  title: JOIN_MEETING,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => JoinMeetingPage()));
                  },
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomGridButton(
                  icon: FontAwesomeIcons.calendarPlus,
                  //bgColor: Colors.deepPurple,
                  title: SCHEDULE,
                  onTap: () {
                    Fluttertoast.showToast(
                      msg: 'This feature is coming soon.',
                      gravity: ToastGravity.SNACKBAR,
                    );
                  },
                ),
                CustomGridButton(
                  icon: FontAwesomeIcons.shareSquare,
                  title: SCREEN_SHARE,
                  onTap: () {
                    Fluttertoast.showToast(
                      msg: 'This feature is coming soon.',
                      gravity: ToastGravity.SNACKBAR,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
}
