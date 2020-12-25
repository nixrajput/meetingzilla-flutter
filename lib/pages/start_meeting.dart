import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meetingzilla/constants/colors.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/models/meeting.dart';
import 'package:meetingzilla/pages/conference_calling_page.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
import 'package:meetingzilla/utils/util_functions.dart';
import 'package:meetingzilla/widgets/custom_app_bar.dart';
import 'package:meetingzilla/widgets/custom_dropdown_btn.dart';
import 'package:meetingzilla/widgets/custom_rounded_btn.dart';

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
  List<Meeting> _meetings = Meeting.getCompanies();
  List<DropdownMenuItem<Meeting>> _dropdownMenuItems;
  Meeting _selectedCompany;

  void _onChangeDropdownItem(Meeting selectedCompany) {
    setState(() {
      _selectedCompany = selectedCompany;
    });
  }

  Future<void> _createChannel() async {
    await handleCameraAndMic();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConferenceCallingPage(
          meetingId: widget.authProvider.meetingId,
          cameraToggle: _cameraToggle,
          micToggle: _micToggle,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _dropdownMenuItems = _buildDropdownMenuItems(_meetings);
    _selectedCompany = _dropdownMenuItems[0].value;
  }

  List<DropdownMenuItem<Meeting>> _buildDropdownMenuItems(List meetings) {
    List<DropdownMenuItem<Meeting>> items = List();
    for (Meeting meeting in meetings) {
      items.add(
        DropdownMenuItem(
          value: meeting,
          child: Text(
            meeting.type,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return items;
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
              _meetingText(),
              _meetingOptions(),
              SizedBox(height: 40.0),
              _meetingButton(),
            ],
          ),
        ),
      );

  Container _meetingText() => Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor.withOpacity(0.3),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.zero,
            bottomLeft: Radius.zero,
            bottomRight: Radius.circular(10.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${MEETING_ID.toUpperCase()} :',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.0),
            Text(
              '${formatMeetingId(widget.authProvider.meetingId)}',
              style: TextStyle(
                color: thirdColor,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  Container _meetingOptions() => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        color: Colors.black.withOpacity(0.1),
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
            Divider(color: Theme.of(context).accentColor),
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
            Divider(color: Theme.of(context).accentColor),
            DropdownButtonHideUnderline(
              child: CustomDropdownButton(
                items: _dropdownMenuItems,
                value: _selectedCompany,
                onChanged: _onChangeDropdownItem,
                hint: Text(
                  MEETING_TYPE,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Container _meetingButton() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CustomRoundedButton(
          onTap: () {
            _createChannel();
          },
          title: START_MEETING.toUpperCase(),
        ),
      );
}
