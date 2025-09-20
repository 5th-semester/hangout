import 'local.dart';
import 'user.dart';

class Meeting {
  final int meeting_id;
  final String name;
  final String description;
  final Local local;
  final List<User> users;
  final DateTime datetime;

  Meeting({
    required this.meeting_id,
    required this.name,
    required this.description,
    required this.local,
    required this.users,
    required this.datetime,
  });
}
