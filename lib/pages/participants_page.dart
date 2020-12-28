import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/repository/firebase_functions.dart';
import 'package:meetingzilla/widgets/custom_app_bar.dart';
import 'package:meetingzilla/widgets/custom_circular_progress.dart';
import 'package:meetingzilla/widgets/rounded_network_image.dart';

class ParticipantsPage extends StatefulWidget {
  final users;
  final String meetingId;

  const ParticipantsPage({
    @required this.users,
    this.meetingId,
  });

  @override
  _ParticipantsPageState createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends State<ParticipantsPage> {
  //AuthProvider _authProvider;
  // List<String> _users = [];

  @override
  void initState() {
    super.initState();
    //_authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
        body: StreamBuilder(
            stream: FirebaseFunctions.meetingCollection
                .doc(widget.meetingId)
                .collection('participants')
                .snapshots(),
            builder: (ctx, snapShots) {
              if (snapShots.hasData) {
                print(snapShots.data.documents);
                return SafeArea(
                  child: Column(
                    children: [
                      CustomAppBar(
                        title: PARTICIPANTS,
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
                      Expanded(child: _bottomBodyArea(bodyHeight, snapShots)),
                    ],
                  ),
                );
              }
              return CustomCircularProgressIndicator(
                color: Theme.of(context).accentColor,
              );
            }));
  }

  Container _bottomBodyArea(height, AsyncSnapshot snapShots) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20.0),
              Text(
                'Total: (${snapShots.data.documents.length})',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: snapShots.data.documents.length,
                itemBuilder: (ctx, i) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        RoundedNetworkImage(
                          imageSize: 40.0,
                          imageUrl: iconUrl,
                          strokeWidth: 0.0,
                          strokeColor: Colors.transparent,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          '${snapShots.data.documents[i]['name']}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.push_pin,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                        SizedBox(width: 10.0),
                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.mic_outlined,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                        SizedBox(width: 10.0),
                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.videocam_outlined,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
