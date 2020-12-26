import 'package:meetingzilla/constants/strings.dart';

class Meeting {
  int id;
  String type;

  Meeting(this.id, this.type);

  static List<Meeting> getCompanies() {
    return <Meeting>[
      Meeting(0, CONFERENCE),
      Meeting(1, CLASSROOM),
    ];
  }
}
