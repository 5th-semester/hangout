import 'package:flutter/material.dart';
import 'pages/login.dart'; // 1. Importe a sua tela de login
import 'package:hangout/pages/home_page.dart';
import 'package:hangout/widgets/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false, // Remove a faixa de "Debug"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // 2. Chame a LoginScreen aqui
    );
  }
}