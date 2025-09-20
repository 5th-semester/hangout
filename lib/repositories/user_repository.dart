import '../../models/user.dart';
import 'mocks/user_mocks.dart';

class UserRepository {
  final List<User> _allUsers= UserMocks.list;

  User getUser(int index) {
    if(_allUsers.isEmpty) {
      return User(user_id: 0, name: "0", email: "0", cpf: "0", password: "0");
    }
    return _allUsers[index];
  }
}