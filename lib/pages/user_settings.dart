import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/user_repository.dart';
import '../widgets/user_data_field.dart';
import '../models/user.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = context.watch<UserRepository>();
    final User? user = userRepository.currentUser;
 
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Minhas informações')),
        body: const Center(child: Text('Nenhum usuário logado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas informações')),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('lib/repositories/images/user.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Text(
                user.name,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            UserField(user: user),
          ],
        ),
      ),
    );
  }
}
