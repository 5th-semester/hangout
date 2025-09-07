import 'dart:async';

import '../../models/user.dart'; // Certifique-se que o caminho para o seu modelo User está correto
import './mocks/user_mocks.dart';
import 'dart:math';

class UserRepository {
  User? _currentUser;
  User? get currentUser => _currentUser;
  
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      final user = UserMocks.list.firstWhere(
        (user) => user.email == email && user.password == password,
      );
      _currentUser = user;
      print('✅ Login bem-sucedido para: ${user.name}');
      return user;
    } catch (e) {
      print('❌ Falha no login: Usuário ou senha inválidos.');
      throw Exception('Usuário ou senha inválidos.');
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_currentUser != null) {
      print('🚪 Logout realizado para: ${_currentUser!.name}');
      _currentUser = null;
    } else {
      print('Nenhum usuário estava logado.');
    }
  }

  Future<User> createUser(String name, String email, String cpf, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Remove a máscara do CPF para salvar e comparar
    final unmaskedCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');

    // Verifica se o email ou CPF já estão em uso
    if (UserMocks.list.any((user) => user.email == email)) {
      print('❌ Falha no cadastro: Email já está em uso.');
      throw Exception('Este email já está em uso.');
    }
    if (UserMocks.list.any((user) => user.cpf == unmaskedCpf)) {
      print('❌ Falha no cadastro: CPF já está em uso.');
      throw Exception('Este CPF já está cadastrado.');
    }

    // Cria um novo usuário com um ID único
    // Em um app real, o ID seria gerado pelo banco de dados
    final newId = (UserMocks.list.map((u) => u.user_id).reduce(max) + 1);

    final newUser = User(
      user_id: newId,
      name: name,
      email: email,
      cpf: unmaskedCpf, // Salva o CPF sem a máscara
      password: password,
    );

    // Adiciona o novo usuário à lista mockada
    UserMocks.list.add(newUser);
    print('✅ Usuário criado com sucesso: ${newUser.name} (ID: ${newUser.user_id})');
    
    // Opcional: Faz o login automático do novo usuário
    _currentUser = newUser;

    return newUser;
  }

  getUser() {}

  updateUser() {}

  deleteUser() {}

}