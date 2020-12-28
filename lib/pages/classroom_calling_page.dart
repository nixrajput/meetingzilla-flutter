import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/pages/participants_page.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
import 'package:meetingzilla/widgets/bottom_bar_btn.dart';
import 'package:meetingzilla/widgets/custom_text_icon_btn.dart';
import 'package:meetingzilla/widgets/setting_custom_text.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

class ClassroomCallingPage extends StatefulWidget {
  final String channelName;

  const ClassroomCallingPage({
    this.channelName,
  });

  @override
  _ClassroomCallingPageState createState() => _ClassroomCallingPageState();
}

class _ClassroomCallingPageState extends State<ClassroomCallingPage> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool _audioMuted = false;

  // bool _muteAllAudio = false;
  // bool _muteAllVideo = false;
  bool _videoMuted = false;
  RtcEngine _engine;
  bool _connecting = false;
  int _uid;
  AuthProvider _authProvider;

  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    Wakelock.disable();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    initialize();
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

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.frameRate = VideoFrameRate.Fps15;
    // configuration.mirrorMode = VideoMirrorMode.Enabled;
    configuration.orientationMode = VideoOutputOrientationMode.Adaptative;
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine
        .joinChannel(null, widget.channelName, null, _authProvider.agoraUserId)
        .then((_) {
      setState(() {
        _connecting = false;
      });
    });
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.Communication);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(
      RtcEngineEventHandler(
        error: (code) {
          final info = 'onError: $code';
          print(info);
          setState(() {
            _infoStrings.add(info);
          });
          Fluttertoast.showToast(
            msg: '$ERROR_OCCUR: $code.',
            gravity: ToastGravity.TOP,
          );
        },
        joinChannelSuccess: (channel, uid, elapsed) {
          final info = 'onJoinChannel: $channel, uid: $uid';
          print(info);
          _users.add(uid);
          setState(() {
            _uid = uid;
            _infoStrings.add(info);
            _infoStrings.add('You joined.');
          });
          Fluttertoast.showToast(
            msg: 'You joined.',
            gravity: ToastGravity.TOP,
          );
        },
        rejoinChannelSuccess: (stat, uid, elapsed) {
          final info = 'onReJoinChannel: $stat';
          print(info);
          setState(() {
            _infoStrings.add(info);
          });
          Fluttertoast.showToast(
            msg: 'You Rejoined. $stat.',
            gravity: ToastGravity.TOP,
          );
        },
        userJoined: (uid, elapsed) {
          final info = 'userJoined: $uid';
          print(info);
          _users.add(uid);
          setState(() {
            _infoStrings.add(info);
          });
          Fluttertoast.showToast(
            msg: '$uid joined.',
            gravity: ToastGravity.CENTER,
          );
        },
        userOffline: (uid, elapsed) {
          final info = 'userOffline: $uid reason: $elapsed';
          print(info);
          _users.remove(uid);
          setState(() {
            _infoStrings.add(info);
          });
          Fluttertoast.showToast(
            msg: '$uid left.',
            gravity: ToastGravity.CENTER,
          );
        },
        connectionLost: () {
          final info = CONN_LOST;
          print(info);
          setState(() {
            _infoStrings.add(info);
          });
          Fluttertoast.showToast(
            msg: CONN_LOST,
            gravity: ToastGravity.TOP,
          );
        },
        connectionInterrupted: () {
          final info = CONN_INTERRUPT;
          print(info);
          setState(() {
            _infoStrings.add(info);
          });
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
          setState(() {
            _infoStrings.add(info);
          });
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
          setState(() {
            _infoStrings.add(info);
          });
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
    return Scaffold(
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
                    Expanded(child: _viewRows(bodyHeight)),
                    _floatingAppBar(),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];

    _users.forEach((uid) {
      if (uid == _authProvider.agoraUserId) {
        list.add(RtcLocalView.SurfaceView());
      } else {
        list.add(RtcRemoteView.SurfaceView(uid: uid));
      }
    });

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

  Widget _viewRows(bodyHeight) {
    final views = _getRenderViews();
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

  Widget _videoView2(view) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      child: view,
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
                          users: _users,
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
                      _audioMuted ? Icons.mic_off_outlined : Icons.mic_outlined,
                  color: _audioMuted ? Colors.redAccent : Colors.transparent,
                  margin: 16.0,
                  padding: 8.0,
                  iconColor: Colors.white,
                ),
                BottomBarButton(
                  onTap: _onToggleVideoMute,
                  icon: _videoMuted
                      ? Icons.videocam_off_outlined
                      : Icons.videocam_outlined,
                  color: _videoMuted ? Colors.redAccent : Colors.transparent,
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
                text: '${widget.channelName}',
                centerText: true,
              ),
              CustomTextArea(
                title: '${YOUR_ID.toUpperCase()} :',
                text: '$_uid',
                centerText: true,
              ),
              CustomTextArea(
                title: '$TOTAL $PARTICIPANTS :'.toUpperCase(),
                text: '${_users.length}',
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
                  CustomTextIconButton(
                    icon: Icons.chat_bubble_outline_outlined,
                    title: '$CHAT',
                    onTap: () {},
                  ),
                  CustomTextIconButton(
                    icon: Icons.screen_share_outlined,
                    title: '$SCREEN_SHARE',
                    onTap: () {},
                  ),
                  CustomTextIconButton(
                    icon: Icons.fiber_smart_record_outlined,
                    title: '$RECORD',
                    onTap: () {},
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomTextIconButton(
                    icon: Icons.report_problem_outlined,
                    title: 'Report problem',
                    onTap: () {},
                  ),
                  CustomTextIconButton(
                    icon: Icons.report_outlined,
                    title: 'Report Abuse',
                    onTap: () {},
                  ),
                  CustomTextIconButton(
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

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleAudioMute() {
    setState(() {
      _audioMuted = !_audioMuted;
    });
    _engine.muteLocalAudioStream(_audioMuted);
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
      _videoMuted = !_videoMuted;
    });
    _engine.muteLocalVideoStream(_videoMuted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }
}
