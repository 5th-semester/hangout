import 'package:flutter/material.dart';
import 'package:hangout/app.dart'; // Importa o novo arquivo app.dart
import 'package:hangout/repositories/meeting_repository.dart';
import 'package:hangout/repositories/user_repository.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  runApp(
    MultiProvider(
      providers: [
        Provider<UserRepository>(create: (_) => UserRepository()),
        ChangeNotifierProvider<MeetingRepository>(
          create: (_) => MeetingRepository(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}