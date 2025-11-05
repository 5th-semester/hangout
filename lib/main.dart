import 'package:flutter/material.dart';
import 'package:hangout/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hangout/repositories/user_repository.dart';
import 'package:hangout/repositories/meeting_repository.dart';
import 'package:hangout/repositories/local_repository.dart';
import 'package:hangout/pages/main_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('pt_BR', null);

  runApp(
    MultiProvider(
      providers: [
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
        ChangeNotifierProvider<UserRepository>(
          create: (context) => UserRepository(
            firebaseAuth: context.read<FirebaseAuth>(),
            firestore: context.read<FirebaseFirestore>(),
          ),
        ),
        ChangeNotifierProvider<MeetingRepository>(
          create: (context) =>
              MeetingRepository(firestore: context.read<FirebaseFirestore>()),
        ),
        Provider<LocalRepository>(
          create: (context) =>
              LocalRepository(firestore: context.read<FirebaseFirestore>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = context.watch<UserRepository>();

    if (userRepository.currentUser == null) {
      return const LoginScreen();
    } else {
      return const MainPage();
    }
  }
}
