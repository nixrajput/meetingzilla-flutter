import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/pages/conference_calling_page.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
import 'package:meetingzilla/utils/util_functions.dart';
import 'package:meetingzilla/widgets/custom_app_bar.dart';
import 'package:meetingzilla/widgets/custom_rounded_btn.dart';
import 'package:meetingzilla/widgets/custom_setting_widget.dart';

class StartMeetingPage extends StatefulWidget {
  final AuthProvider authProvider;

  const StartMeetingPage({@required this.authProvider})
      : assert(authProvider != null);

  @override
  _StartMeetingPageState createState() => _StartMeetingPageState();
}

class _StartMeetingPageState extends State<StartMeetingPage> {
  bool _micToggle = true;
  bool _cameraToggle = true;
  bool _meetingIdToggle = false;
  final _topicController = TextEditingController();

  Future<void> _createChannel() async {
    await handleCameraAndMic();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConferenceCallingPage(
          meetingId: widget.authProvider.meetingId,
          cameraToggle: _cameraToggle,
          micToggle: _micToggle,
          role: HOST,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _topicController.dispose();
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
              title: NEW_MEETING,
              titleColor: Theme.of(context).textTheme.subtitle1.color,
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20.0),
              _meetingOptions(),
              SizedBox(height: 40.0),
              _meetingButton(),
            ],
          ),
        ),
      );

  Container _meetingOptions() => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: Column(
          children: [
            TextFormField(
              key: ValueKey(TOPIC),
              keyboardType: TextInputType.number,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _topicController,
              decoration: InputDecoration(
                labelText: TOPIC.toUpperCase(),
              ),
            ),
            SizedBox(height: 16.0),
            CustomSettingWidget(
              leading: Text(
                "RANDOM MEETING ID",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Checkbox(
                tristate: false,
                hoverColor: Theme.of(context).accentColor.withOpacity(0.7),
                value: _meetingIdToggle,
                onChanged: (value) {
                  setState(() {
                    _meetingIdToggle = value;
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            CustomSettingWidget(
              leading: Text(
                CAMERA.toUpperCase(),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Switch(
                value: _cameraToggle,
                onChanged: (value) {
                  setState(() {
                    _cameraToggle = !_cameraToggle;
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            CustomSettingWidget(
              leading: Text(
                AUDIO.toUpperCase(),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Switch(
                value: _micToggle,
                onChanged: (value) {
                  setState(() {
                    _micToggle = !_micToggle;
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      );

  Container _meetingButton() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CustomRoundedBtn(
          onTap: () {
            _createChannel();
          },
          title: START_MEETING.toUpperCase(),
          titleColor: Colors.white,
        ),
      );
}
