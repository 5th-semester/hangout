import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final _userLocation = Coordinates(latitude: -25.095, longitude: -50.162);

  Future<void> _refreshMeetings() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final meetingRepository = context.watch<MeetingRepository>();

    final meetings = meetingRepository.getPaginatedMeetingsByProximity(
      userCoordinates: _userLocation,
      itemsPerPage: 10,
    );

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
        onRefresh: _refreshMeetings,
        child: meetings.isEmpty
            ? _buildEmptyState()
            : _buildMeetingsList(meetings),
      ),
    );
  }

  Widget _buildMeetingsList(List<Meeting> meetings) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        return MeetingCard(
          meeting: meeting,
          onSeeMorePressed: () {
            // TODO: Implementar navegação para a página de detalhes do evento
            print('Navegando para detalhes do evento: ${meeting.name}');
          },
          onSubscribePressed: () {
            // TODO: Implementar a lógica de inscrição real usando o repositório
            print('Inscrição no evento: ${meeting.name}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Inscrição em "${meeting.name}" realizada com sucesso!',
                ),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
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
                      'Que tal criar o primeiro? Use o botão "+" para começar!',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
