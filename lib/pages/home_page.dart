import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hangout/repositories/user_repository.dart';
import '../widgets/meeting_card.dart';
import '../repositories/meeting_repository.dart';
import 'meeting_details_page.dart';
import '../models/meeting.dart';
import '../models/coordinates.dart';
import '../models/user.dart';

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

  void _handleSubscription(Meeting meeting) {
    if (meeting.users.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este evento já atingiu o número máximo de participantes.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userRepository = context.read<UserRepository>();
    final meetingRepository = context.read<MeetingRepository>();
    final User? currentUser = userRepository.currentUser;

    if (currentUser != null) {
      meetingRepository.subscribeToMeeting(meeting: meeting, user: currentUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Inscrição em "${meeting.name}" realizada com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado para se inscrever.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meetingRepository = context.watch<MeetingRepository>();
    final currentUser = context.watch<UserRepository>().currentUser;

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
              /* TODO */
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMeetings,
        child: meetings.isEmpty
            ? _buildEmptyState()
            : _buildMeetingsList(meetings, meetingRepository, currentUser),
      ),
    );
  }

  Widget _buildMeetingsList(
    List<Meeting> meetings,
    MeetingRepository repository,
    User? currentUser,
  ) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        final bool isSubscribed = repository.isUserSubscribed(
          meeting: meeting,
          user: currentUser,
        );

        return MeetingCard(
          meeting: meeting,
          isSubscribed: isSubscribed,
          onSeeMorePressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MeetingDetailsPage(meeting: meeting),
              ),
            );
          },
          onSubscribePressed: () => _handleSubscription(meeting),
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
