import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hangout/pages/login.dart';
import '../repositories/user_repository.dart';
import '../widgets/user_data_field.dart';
import '../models/user.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  final _repository = UserRepository();
  late User _user;

  @override
  void initState() {
    super.initState();

    _user = _repository.getUser(1);
  }

  // NOVO: realiza logout usando o UserRepository do Provider
  Future<void> _logout() async {
    try {
      final repo = context.read<UserRepository>();
      await repo.logout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout realizado com sucesso.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deslogar: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                decoration: BoxDecoration(
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
                _user.name,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            UserField(user: _user),
            const SizedBox(height: 20),
            // NOVO: Tile de logout nas configurações
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
              title: const Text('Sair', style: TextStyle(color: Colors.redAccent)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
