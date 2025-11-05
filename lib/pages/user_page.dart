import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/user_repository.dart';
import '../models/user.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  @override
  void initState() {
    super.initState();
  }

  @override 
  Widget build(BuildContext context) {
    final userRepository = context.watch<UserRepository>();
    final User? user = userRepository.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(child: Text('Nenhum usuário logado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
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
                    image:  AssetImage('lib/repositories/images/user.png'),
                    fit: BoxFit.fill
                  ),
                ),
              )
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Text(
                user.name,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold
                ),
              )
            ),
            SizedBox(
              width: 380,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:EdgeInsetsGeometry.only(left: 10, top: 7),
                      child: Text(
                        "Bio",
                        style: TextStyle(
                          fontSize: 22
                        )
                        )
                    ),
                    Padding(
                      padding:EdgeInsetsGeometry.only(top: 5, right: 10, bottom: 10, left: 10),
                      child: Text(
                        "Lorem ipsum dolor sit amet consectetur adipiscing elit. Quisque faucibus ex sapien vitae pellentesque sem placerat. In id cursus mi pretium tellus duis convallis. Tempus leo eu aenean sed diam urna tempor.",
                        style: TextStyle(
                          fontSize: 15
                        )
                      )
                    )
                  ]
                )
              )
            )
          ]     
        )
      ) 
    );
  }
}