import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/user_repository.dart';
import '../repositories/meeting_repository.dart';
import '../models/meeting.dart';
import '../models/user.dart';
import '../widgets/meeting_card.dart';

class MyEventsPage extends StatelessWidget {
  const MyEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final meetingRepository = context.watch<MeetingRepository>();
    final userRepository = context.watch<UserRepository>();
    final currentUser = userRepository.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Eventos')),
      body: _buildBody(context, meetingRepository, currentUser),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MeetingRepository meetingRepo,
    User? currentUser,
  ) {
    if (currentUser == null) {
      return const Center(
        child: Text('Faça login para ver seus eventos inscritos.'),
      );
    }

    final myMeetings = meetingRepo.getSubscribedMeetings(user: currentUser);

    if (myMeetings.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildMeetingsList(context, myMeetings);
  }

  Widget _buildMeetingsList(BuildContext context, List<Meeting> meetings) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];

        return MeetingCard(
          meeting: meeting,
          isSubscribed: true,
          onSeeMorePressed: () {
            // TODO: Navegar para a tela de detalhes do evento.
            print('Ver detalhes do evento: ${meeting.name}');
          },
          onSubscribePressed: () {},
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Você ainda não se inscreveu em nenhum evento.',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Explore os eventos na tela inicial e participe!',
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
