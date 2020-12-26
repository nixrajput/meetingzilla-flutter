import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/pages/participants_page.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
import 'package:meetingzilla/providers/channel_provider.dart';
import 'package:meetingzilla/repository/firebase_functions.dart';
import 'package:meetingzilla/widgets/bottom_bar_btn.dart';
import 'package:meetingzilla/widgets/custom_circular_progress.dart';
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
  bool _connecting = false, _isJoined = false, _switchRender = true;
  int _uid;
  AuthProvider _authProvider;
  ChannelProvider _channelProvider;

  List<int> _participants = [];

  Future<void> _initMeetingData() async {
    await FirebaseFunctions.meetingCollection
        .doc(widget.meetingId)
        .collection('participants')
        .doc('${_authProvider.agoraUserId}')
        .set({
      'startAt': DateTime.now().toString(),
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
    await _engine?.setVideoEncoderConfiguration(configuration);
    await _engine?.joinChannel(
        null, widget.meetingId, null, _authProvider.agoraUserId);
    setState(() {
      _connecting = false;
    });
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine?.enableVideo();
    await _engine?.setChannelProfile(ChannelProfile.Communication);
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
            _isJoined = true;
          });
          Fluttertoast.showToast(
            msg: 'You joined.',
            gravity: ToastGravity.TOP,
          );
        },
        userJoined: (uid, elapsed) {
          final info = 'userJoined: $uid';
          print(info);
          setState(() {
            _participants.add(uid);
          });
          Fluttertoast.showToast(
            msg: '$uid joined.',
            gravity: ToastGravity.CENTER,
          );
        },
        userOffline: (uid, elapsed) {
          final info = 'userOffline: $uid reason: $elapsed';
          print(info);
          setState(() {
            _participants.removeWhere((element) => element == uid);
          });
          Fluttertoast.showToast(
            msg: '$uid left.',
            gravity: ToastGravity.CENTER,
          );
        },
        leaveChannel: (stats) {
          log('leaveChannel ${stats.toJson()}');
          setState(() {
            _isJoined = false;
            _participants.clear();
          });
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
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _channelProvider = Provider.of<ChannelProvider>(context, listen: false);
    initialize();
    setState(() {
      _cameraToggle = widget.cameraToggle ?? true;
      _micToggle = widget.micToggle ?? true;
    });
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.destroy();
    FirebaseFunctions.meetingCollection
        .doc(widget.meetingId)
        .collection('participants')
        .doc('${_authProvider.agoraUserId}')
        .update({'endAt': DateTime.now().toString()});
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return StreamBuilder(
      stream: FirebaseFunctions.meetingCollection
          .doc(widget.meetingId)
          .collection('participants')
          .snapshots(),
      builder: (_, _meetingSnapshots) => Scaffold(
        backgroundColor: Colors.black,
        body: _connecting
            ? Center(
                child: CustomCircularProgressIndicator(
                  color: Theme.of(context).accentColor,
                ),
              )
            : SafeArea(child: _renderVideo(bodyHeight, _meetingSnapshots)),
      ),
    );
  }

  void switchRender() {
    setState(() {
      _switchRender = !_switchRender;
      _participants = List.of(_participants.reversed);
    });
  }

  Widget _renderVideo(bodyHeight, AsyncSnapshot meetingSnapshots) {
    return Stack(
      children: [
        RtcLocalView.SurfaceView(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_participants != null && _participants.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        List.of(_participants.map((uid) => GestureDetector(
                              onTap: switchRender,
                              child: Container(
                                padding: const EdgeInsets.only(left: 8.0),
                                color: Colors.transparent,
                                width: 120.0,
                                height: 140.0,
                                child: Stack(
                                  children: [
                                    RtcRemoteView.SurfaceView(uid: uid),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 4.0,
                                        left: 4.0,
                                      ),
                                      child: Text(
                                        uid.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                  ),
                ),
              _floatingControlBar(),
            ],
          ),
        ),
      ],
    );
  }

  Container _floatingControlBar() => Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          top: 8.0,
          bottom: 8.0,
          left: 8.0,
          right: 8.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomBarButton(
              onTap: () => _onCallEnd(context),
              icon: FontAwesomeIcons.times,
              color: Colors.red,
              borderColor: Colors.red,
              padding: 20.0,
            ),
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
              icon: FontAwesomeIcons.users,
            ),
            BottomBarButton(
              onTap: _onToggleAudioMute,
              icon: !_micToggle
                  ? FontAwesomeIcons.microphoneSlash
                  : FontAwesomeIcons.microphone,
              color: !_micToggle ? Colors.redAccent : Colors.transparent,
            ),
            BottomBarButton(
              onTap: _onToggleVideoMute,
              icon: !_cameraToggle
                  ? FontAwesomeIcons.videoSlash
                  : FontAwesomeIcons.video,
              color: !_cameraToggle ? Colors.redAccent : Colors.transparent,
            ),
            BottomBarButton(
              onTap: () => _showMoreOptionsBottomSheet(context),
              icon: FontAwesomeIcons.ellipsisH,
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
                MEETING_DETAILS,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).accentColor,
                ),
              ),
              SizedBox(height: 20.0),
              CustomTextArea(
                title: '$MEETING_ID :',
                text: '${widget.meetingId}',
                centerText: true,
              ),
              CustomTextArea(
                title: '$YOUR_ID :',
                text: '$_uid',
                centerText: true,
              ),
              CustomTextArea(
                title: '$TOTAL $PARTICIPANTS :',
                text: '${_participants.length + 1}',
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
                '$MORE_OPTIONS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).accentColor,
                ),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomIconButton(
                    icon: FontAwesomeIcons.infoCircle,
                    iconColor: Theme.of(context).accentColor,
                    onTap: () {
                      _showDetailsBottomSheet(ctx);
                    },
                  ),
                  CustomIconButton(
                    icon: FontAwesomeIcons.exchangeAlt,
                    iconColor: Theme.of(context).accentColor,
                    onTap: _onSwitchCamera,
                  ),
                  CustomIconButton(
                    icon: FontAwesomeIcons.shareAlt,
                    iconColor: Theme.of(context).accentColor,
                    onTap: () {},
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomIconButton(
                    icon: FontAwesomeIcons.chromecast,
                    iconColor: Theme.of(context).accentColor,
                    onTap: () {},
                  ),
                  CustomIconButton(
                    icon: FontAwesomeIcons.bug,
                    iconColor: Theme.of(context).accentColor,
                    onTap: () {},
                  ),
                  CustomIconButton(
                    icon: FontAwesomeIcons.cog,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  void _onCallEnd(BuildContext context) async {
    await FirebaseFunctions.meetingCollection
        .doc(widget.meetingId)
        .collection('participants')
        .doc('${_authProvider.agoraUserId}')
        .update({'endAt': DateTime.now().toString()});
    Navigator.pop(context);
  }

  void _onToggleAudioMute() {
    setState(() {
      _micToggle = !_micToggle;
    });
    _engine?.muteLocalAudioStream(_micToggle);
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
    _engine?.muteLocalVideoStream(_cameraToggle);
  }

  void _onSwitchCamera() {
    _engine?.switchCamera();
  }
}
