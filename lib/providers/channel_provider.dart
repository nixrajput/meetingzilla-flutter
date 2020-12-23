import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:meetingzilla/repository/firebase_functions.dart';

class ChannelProvider with ChangeNotifier {
  Stream<DocumentSnapshot> _meetingSnapshots;

  Stream<DocumentSnapshot> get meetingSnapshots => _meetingSnapshots;

  Future<void> getMeetingData(String meetingId) async {
    _meetingSnapshots =
        FirebaseFunctions.meetingCollection.doc(meetingId).snapshots();
  }
}
