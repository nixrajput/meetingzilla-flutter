import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/pages/conference_calling_page.dart';
import 'package:meetingzilla/utils/util_functions.dart';
import 'package:meetingzilla/widgets/custom_app_bar.dart';
import 'package:meetingzilla/widgets/custom_rounded_btn.dart';

class JoinMeetingPage extends StatefulWidget {
  @override
  _JoinMeetingPageState createState() => _JoinMeetingPageState();
}

class _JoinMeetingPageState extends State<JoinMeetingPage> {
  bool _micToggle = true;
  bool _cameraToggle = true;
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
          role: CO_HOST,
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
            CustomAppBar(
              title: JOIN_MEETING,
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

  Container _bottomBodyArea(height) => Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20.0),
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
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.zero,
                      bottomLeft: Radius.zero,
                      bottomRight: Radius.circular(16.0),
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
              SizedBox(height: 20.0),
              _meetingOptions(),
              SizedBox(height: 40.0),
              CustomRoundedBtn(
                onTap: () {
                  _joinChannel(_meetingIdController.text.trim());
                },
                title: JOIN_MEETING.toUpperCase(),
              ),
            ],
          ),
        ),
      );

  Container _meetingOptions() => Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CAMERA.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _cameraToggle,
                  onChanged: (value) {
                    setState(() {
                      _cameraToggle = !_cameraToggle;
                    });
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            //Divider(color: Theme.of(context).accentColor),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AUDIO.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _micToggle,
                  onChanged: (value) {
                    setState(() {
                      _micToggle = !_micToggle;
                    });
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
      );
}
