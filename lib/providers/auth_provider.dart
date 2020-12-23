import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/repository/firebase_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  var _meetingId;
  var _agoraUserId;
  bool _userDataEmpty;
  bool _loggedIn;
  DocumentSnapshot _userSnapshot;

  String get meetingId => _meetingId;

  int get agoraUserId => _agoraUserId;

  bool get userDataEmpty => _userDataEmpty;

  bool get loggedIn => _loggedIn;

  DocumentSnapshot get userSnapshot => _userSnapshot;

  Future<void> checkUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(USER_DATA)) {
      _userDataEmpty = true;
    } else {
      _userDataEmpty = false;
    }
    if (prefs.containsKey(USER_DATA)) {
      final userData =
          json.decode(prefs.getString(USER_DATA)) as Map<String, Object>;
      _meetingId = userData[CHANNEL_ID];
      _agoraUserId = userData[UID];
    }
    notifyListeners();
  }

  Future<void> getUserInfo(String userId) async {
    _userSnapshot = await FirebaseFunctions.userCollection.doc(userId).get();
  }

  Future<void> saveLocalUserData(String channelId, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final _userData = json.encode({
      CHANNEL_ID: channelId,
      UID: userId,
    });
    await prefs.setString(USER_DATA, _userData);
  }
}
