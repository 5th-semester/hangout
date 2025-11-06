import '../repositories/user_repository.dart';
import '../models/user.dart';

class UserService {
  final UserRepository repository;

  UserService({required this.repository});

  User? get currentUser => repository.currentUser;

  Future<void> login(String email, String password) =>
      repository.login(email, password);

  Future<void> createUser({
    required String name,
    required String email,
    required String cpf,
    required String password,
  }) =>
      repository.createUser(
        name: name,
        email: email,
        cpf: cpf,
        password: password,
      );

  Future<void> logout() => repository.logout();

  Future<List<User>> getUsersFromIds(List<String> ids) =>
      repository.getUsersFromIds(ids);
}
