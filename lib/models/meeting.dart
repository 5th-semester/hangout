import 'local.dart';
import 'user.dart';

class Meeting {
  Local local;
  List<User> users;
  DateTime datetime;

  Meeting({required this.local, required this.users, required this.datetime});
}
