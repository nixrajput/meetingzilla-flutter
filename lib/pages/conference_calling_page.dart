import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/pages/participants.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
import 'package:meetingzilla/providers/channel_provider.dart';
import 'package:meetingzilla/repository/firebase_functions.dart';
import 'package:meetingzilla/widgets/bottom_bar_btn.dart';
import 'package:meetingzilla/widgets/custom_icon_btn.dart';
import 'package:meetingzilla/widgets/setting_custom_text.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

class ConferenceCallingPage extends StatefulWidget {
  final String meetingId;
  final bool cameraToggle;
  final bool micToggle;

  const ConferenceCallingPage({
    @required this.meetingId,
    @required this.cameraToggle,
    @required this.micToggle,
  }) : assert(meetingId != null);

  @override
  _ConferenceCallingPageState createState() => _ConferenceCallingPageState();
}

class _ConferenceCallingPageState extends State<ConferenceCallingPage> {
  // bool _muteAllAudio = false;
  // bool _muteAllVideo = false;
  bool _micToggle;
  bool _cameraToggle;
  RtcEngine _engine;
  bool _connecting = false;
  int _uid;
  AuthProvider _authProvider;
  ChannelProvider _channelProvider;

  List<String> _participants = [];

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.destroy();
    FirebaseFunctions.meetingCollection
        .doc(widget.meetingId)
        .collection('participants')
        .doc('${_authProvider.agoraUserId}')
        .delete();
    Wakelock.disable();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _channelProvider = Provider.of<ChannelProvider>(context, listen: false);
    initialize();
  }

  Future<void> _initMeetingData() async {
    await FirebaseFunctions.meetingCollection
        .doc(widget.meetingId)
        .collection('participants')
        .doc('${_authProvider.agoraUserId}')
        .set({
      'startAt': DateTime.now().toString(),
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> initialize() async {
    Wakelock.enable();
    setState(() {
      _connecting = true;
    });
    if (APP_ID.isEmpty) {
      Fluttertoast.showToast(
        msg: APP_ID_MISSING_WARNING,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    await _initMeetingData();
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.frameRate = VideoFrameRate.Fps15;
    configuration.orientationMode = VideoOutputOrientationMode.Adaptative;
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine
        .joinChannel(null, widget.meetingId, null, _authProvider.agoraUserId)
        .then((_) {
      setState(() {
        _connecting = false;
      });
    });
    _engine.muteLocalVideoStream(widget.cameraToggle);
    _engine.muteLocalAudioStream(widget.micToggle);
    setState(() {
      _cameraToggle = widget.cameraToggle;
      _micToggle = widget.micToggle;
    });
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.Communication);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(
      RtcEngineEventHandler(
        error: (code) {
          final info = 'onError: $code';
          print(info);
          Fluttertoast.showToast(
            msg: '$ERROR_OCCUR: $code.',
            gravity: ToastGravity.TOP,
          );
        },
        joinChannelSuccess: (channel, uid, elapsed) {
          final info = 'onJoinChannel: $channel, uid: $uid';
          print(info);
          setState(() {
            _uid = uid;
          });
          Fluttertoast.showToast(
            msg: 'You joined.',
            gravity: ToastGravity.TOP,
          );
        },
        rejoinChannelSuccess: (stat, uid, elapsed) {
          final info = 'onReJoinChannel: $stat';
          print(info);
          Fluttertoast.showToast(
            msg: 'You Rejoined. $stat.',
            gravity: ToastGravity.TOP,
          );
        },
        userJoined: (uid, elapsed) {
          final info = 'userJoined: $uid';
          print(info);

          Fluttertoast.showToast(
            msg: '$uid joined.',
            gravity: ToastGravity.CENTER,
          );
        },
        userOffline: (uid, elapsed) {
          final info = 'userOffline: $uid reason: $elapsed';
          print(info);
          Fluttertoast.showToast(
            msg: '$uid left.',
            gravity: ToastGravity.CENTER,
          );
        },
        connectionLost: () {
          final info = CONN_LOST;
          print(info);

          Fluttertoast.showToast(
            msg: CONN_LOST,
            gravity: ToastGravity.TOP,
          );
        },
        connectionInterrupted: () {
          final info = CONN_INTERRUPT;
          print(info);

          Fluttertoast.showToast(
            msg: CONN_INTERRUPT,
            gravity: ToastGravity.TOP,
          );
        },
        userMuteAudio: (uid, audioMuted) {
          String info;
          if (audioMuted) {
            info = '$uid muted audio.';
          } else {
            info = '$uid unmuted audio.';
          }
          print(info);

          Fluttertoast.showToast(
            msg: info,
            gravity: ToastGravity.TOP,
          );
        },
        userMuteVideo: (uid, videoMuted) {
          String info;
          if (videoMuted) {
            info = '$uid muted video.';
          } else {
            info = '$uid unmuted video.';
          }
          print(info);

          Fluttertoast.showToast(
            msg: info,
            gravity: ToastGravity.TOP,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return StreamBuilder(
      stream: FirebaseFunctions.meetingCollection
          .doc(widget.meetingId)
          .collection('participants')
          .orderBy('timestamp')
          .snapshots(),
      builder: (_, _meetingSnapshots) => Scaffold(
        backgroundColor: Colors.black,
        body: _connecting
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              )
            : SafeArea(
                child: Container(
                  height: bodyHeight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _topAppBar(bodyHeight),
                      Expanded(child: _viewRows(bodyHeight, _meetingSnapshots)),
                      _floatingAppBar(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _getRenderViews(_participants) {
    final List<Widget> list = [];

    for (int i = 0; i < _participants.length; i++) {
      if (int.parse(_participants[i].id) == _authProvider.agoraUserId) {
        list.add(RtcLocalView.SurfaceView());
      } else {
        list.add(Stack(
          children: [
            RtcRemoteView.SurfaceView(uid: int.parse(_participants[i].id)),
            Positioned(
              top: 0,
              left: 0,
              child: Text(
                _participants[i].id,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ));
      }
    }
    return list;
  }

  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  Widget _videoView2(view) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      child: view,
    );
  }

  Widget _viewRows(bodyHeight, AsyncSnapshot meetingSnapshots) {
    final views = _getRenderViews(meetingSnapshots.data.documents);
    if (views.length == 1)
      return Container(
          child: Column(
        children: <Widget>[_videoView(views[0])],
      ));

    if (views.length == 2)
      return Container(
          child: Column(
        children: <Widget>[
          _expandedVideoRow([views[0]]),
          _expandedVideoRow([views[1]])
        ],
      ));

    if (views.length == 3)
      return Container(
          child: Column(
        children: <Widget>[
          _expandedVideoRow(views.sublist(0, 2)),
          _expandedVideoRow(views.sublist(2, 3))
        ],
      ));

    if (views.length == 4)
      return Container(
          child: Column(
        children: <Widget>[
          _expandedVideoRow(views.sublist(0, 2)),
          _expandedVideoRow(views.sublist(2, 4))
        ],
      ));

    if (views.length >= 5) {
      final wrappedViews = views.sublist(2, views.length);
      return Container(
        child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: wrappedViews.map<Widget>(_videoView2).toList(),
              ),
            ),
          ],
        ),
      );
    }
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Container _floatingAppBar() => Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RaisedButton(
              onPressed: () => _onCallEnd(context),
              color: Colors.red,
              elevation: 0.0,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(const Radius.circular(60.0)),
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BottomBarButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ParticipantsPage(
                          users: _participants,
                        ),
                      ),
                    );
                  },
                  icon: Icons.group_outlined,
                  padding: 8.0,
                  iconColor: Colors.white,
                ),
                BottomBarButton(
                  onTap: _onToggleAudioMute,
                  icon:
                      !_micToggle ? Icons.mic_off_outlined : Icons.mic_outlined,
                  color: !_micToggle ? Colors.redAccent : Colors.transparent,
                  margin: 16.0,
                  padding: 8.0,
                  iconColor: Colors.white,
                ),
                BottomBarButton(
                  onTap: _onToggleVideoMute,
                  icon: !_cameraToggle
                      ? Icons.videocam_off_outlined
                      : Icons.videocam_outlined,
                  color: !_cameraToggle ? Colors.redAccent : Colors.transparent,
                  padding: 8.0,
                  iconColor: Colors.white,
                ),
                BottomBarButton(
                  onTap: _onSwitchCamera,
                  icon: Icons.repeat_outlined,
                  iconColor: Colors.white,
                  margin: 16.0,
                  padding: 8.0,
                ),
              ],
            ),
          ],
        ),
      );

  _showDetailsBottomSheet(BuildContext ctx) => showModalBottomSheet(
        context: ctx,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        ),
        builder: (ctx) => Container(
          padding: const EdgeInsets.only(
            top: 10.0,
            bottom: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.0),
              Text(
                MEETING_DETAILS.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).accentColor,
                ),
              ),
              SizedBox(height: 20.0),
              CustomTextArea(
                title: '${MEETING_ID.toUpperCase()} :',
                text: '${widget.meetingId}',
                centerText: true,
              ),
              CustomTextArea(
                title: '${YOUR_ID.toUpperCase()} :',
                text: '$_uid',
                centerText: true,
              ),
              CustomTextArea(
                title: '$TOTAL $PARTICIPANTS :'.toUpperCase(),
                text: '${_participants.length}',
                centerText: true,
              ),
            ],
          ),
        ),
      );

  _showMoreOptionsBottomSheet(BuildContext ctx) => showModalBottomSheet(
        context: ctx,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        ),
        builder: (ctx) => Container(
          padding: const EdgeInsets.only(
            top: 10.0,
            bottom: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.0),
              Text(
                '$MORE_OPTIONS'.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).accentColor,
                ),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomIconButton(
                    icon: Icons.chat_bubble_outline_outlined,
                    title: '$CHAT',
                    onTap: () {},
                  ),
                  CustomIconButton(
                    icon: Icons.screen_share_outlined,
                    title: '$SCREEN_SHARE',
                    onTap: () {},
                  ),
                  CustomIconButton(
                    icon: Icons.fiber_smart_record_outlined,
                    title: '$RECORD',
                    onTap: () {},
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomIconButton(
                    icon: Icons.report_problem_outlined,
                    title: 'Report problem',
                    onTap: () {},
                  ),
                  CustomIconButton(
                    icon: Icons.report_outlined,
                    title: 'Report Abuse',
                    onTap: () {},
                  ),
                  CustomIconButton(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Container _topAppBar(deviceSize) => Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                _showDetailsBottomSheet(context);
              },
              child: Icon(
                Icons.info_outline,
                size: 32.0,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                _showMoreOptionsBottomSheet(context);
              },
              child: Icon(
                Icons.more_vert_outlined,
                size: 32.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );

  void _onCallEnd(BuildContext context) async {
    await FirebaseFunctions.meetingCollection
        .doc(widget.meetingId)
        .collection('participants')
        .doc('${_authProvider.agoraUserId}')
        .delete();
    Navigator.pop(context);
  }

  void _onToggleAudioMute() {
    setState(() {
      _micToggle = !_micToggle;
    });
    _engine.muteLocalAudioStream(_micToggle);
  }

  // void _onToggleAllRemoteAudioMute() {
  //   setState(() {
  //     _muteAllAudio = !_muteAllAudio;
  //   });
  //   _engine.muteAllRemoteAudioStreams(_muteAllAudio);
  // }
  //
  // void _onToggleAllRemoteVideoMute() {
  //   setState(() {
  //     _muteAllVideo = !_muteAllVideo;
  //   });
  //   _engine.muteAllRemoteVideoStreams(_muteAllVideo);
  // }

  void _onToggleVideoMute() {
    setState(() {
      _cameraToggle = !_cameraToggle;
    });
    _engine.muteLocalVideoStream(_cameraToggle);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }
}
