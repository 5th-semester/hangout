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

  Future<void> _loadMeetings() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _meetings = _repository.getPaginatedMeetingsByProximity(
        userCoordinates: _userLocation,
        itemsPerPage: 10,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos Próximos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              /* TODO: Implementar lógica de filtro */
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMeetings,
        child: _meetings.isEmpty ? _buildEmptyState() : _buildMeetingsList(),
      ),
    );
  }

  Widget _buildMeetingsList() {
    return ListView.builder(
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Nenhum evento por perto.',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Que tal criar o primeiro? Use o botão "+" abaixo!',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
