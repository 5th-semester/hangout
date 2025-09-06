import 'local.dart';
import 'user.dart';

class Meeting {
  int meeting_id;
  String name;
  String description;
  Local local;
  List<User> users;
  DateTime datetime;

  Meeting({
    required this.meeting_id,
    required this.name,
    required this.description,
    required this.local,
    required this.users,
    required this.datetime,
  });
}
