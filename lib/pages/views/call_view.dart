import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(height: height * 0.03),
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      PID_IS,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${formatMeetingId(widget.authProvider.meetingId)}",
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: thirdColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.05),
              GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 1.0,
                  crossAxisCount: 2,
                ),
                shrinkWrap: true,
                physics: ScrollPhysics(),
                children: [
                  CustomGridButton(
                    icon: Icons.video_call_rounded,
                    title: START_MEETING,
                    onPressed: () {
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
                    icon: Icons.videocam_rounded,
                    //bgColor: Colors.indigo,
                    title: JOIN_MEETING,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => JoinMeetingPage()));
                    },
                  ),
                  CustomGridButton(
                    icon: Icons.schedule_rounded,
                    //bgColor: Colors.deepPurple,
                    title: SCHEDULE,
                    onPressed: () {
                      Fluttertoast.showToast(
                        msg: 'This feature is coming soon.',
                        gravity: ToastGravity.CENTER,
                      );
                    },
                  ),
                  CustomGridButton(
                    icon: Icons.screen_share_rounded,
                    //bgColor: Colors.orangeAccent,
                    title: SCREEN_SHARE,
                    onPressed: () {
                      Fluttertoast.showToast(
                        msg: 'This feature is coming soon.',
                        gravity: ToastGravity.CENTER,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
