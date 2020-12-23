import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/pages/conference_calling_page.dart';
import 'package:meetingzilla/utils/util_functions.dart';
import 'package:meetingzilla/widgets/custom_rounded_btn.dart';

class JoinMeetingPage extends StatefulWidget {
  @override
  _JoinMeetingPageState createState() => _JoinMeetingPageState();
}

class _JoinMeetingPageState extends State<JoinMeetingPage> {
  final _meetingIdController = TextEditingController();

  Future<void> _joinChannel(String channelId) async {
    await handleCameraAndMic();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConferenceCallingPage(
          meetingId: channelId,
          cameraToggle: true,
          micToggle: true,
        ),
      ),
    );
    //_meetingIdController.clear();
  }

  @override
  void dispose() {
    _meetingIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _topBodyArea(bodyHeight),
            Expanded(child: _bottomBodyArea(bodyHeight)),
          ],
        ),
      ),
    );
  }

  Container _topBodyArea(height) => Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Join Meeting',
                    style: TextStyle(
                      fontSize: height * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_outlined,
                      color: Theme.of(context).accentColor,
                      size: 40.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Container _bottomBodyArea(height) => Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10.0),
              TextFormField(
                key: ValueKey(MEETING_ID),
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _meetingIdController,
                inputFormatters: [
                  // MeetingIdFormatter(mask: "xxx xxx xxxx", separator: " "),
                ],
                decoration: InputDecoration(
                  labelText: MEETING_ID.toUpperCase(),
                  errorMaxLines: 2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.zero,
                      bottomLeft: Radius.zero,
                      bottomRight: Radius.circular(20.0),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return "Meeting ID can't be empty.";
                  } else if (value.length <= 9) {
                    return "Meeting ID is invalid.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 40.0),
              CustomRoundedButton(
                onTap: () {
                  _joinChannel(_meetingIdController.text.trim());
                },
                title: JOIN_MEETING.toUpperCase(),
              )
            ],
          ),
        ),
      );
}
