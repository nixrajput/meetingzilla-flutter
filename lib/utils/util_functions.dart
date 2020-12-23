import 'package:permission_handler/permission_handler.dart';

String formatMeetingId(String id) {
  final meetingId = id.replaceAllMapped(
      RegExp(r'(\d{3})(\d{3})(\d+)'), (Match m) => "${m[1]} ${m[2]} ${m[3]}");
  return meetingId;
}

Future<void> handleCameraAndMic() async {
  await [
    Permission.camera,
    Permission.microphone,
  ].request();
}
