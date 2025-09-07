import 'package:flutter/material.dart';
import '../widgets/meeting_card.dart';
import '../repositories/meeting_repository.dart';
import '../models/meeting.dart';
import '../models/coordinates.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repository = MeetingRepository();
  late List<Meeting> _meetings;

  final _userLocation = Coordinates(latitude: -25.095, longitude: -50.162);

  @override
  void initState() {
    super.initState();

    _meetings = _repository.getPaginatedMeetingsByProximity(
      userCoordinates: _userLocation,
      itemsPerPage: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encontros Próximos')),
      body: ListView.builder(
        itemCount: _meetings.length,
        itemBuilder: (context, index) {
          final meeting = _meetings[index];
          return MeetingCard(
            meeting: meeting,
            onSeeMorePressed: () {
              print('Navegando para detalhes do evento: ${meeting.name}');
            },
            onSubscribePressed: () {
              print('Inscrição no evento: ${meeting.name}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Inscrição em "${meeting.name}" realizada!'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
