import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/user_repository.dart';
import '../repositories/meeting_repository.dart';
import '../repositories/local_repository.dart';
import '../services/meeting_service.dart';
import '../services/local_service.dart';
import '../services/user_service.dart';
import '../models/meeting.dart';
import '../models/user.dart';
import '../models/local.dart';
import '../widgets/meeting_card.dart';
import 'meeting_details_page.dart';

class MyEventsPage extends StatelessWidget {
  const MyEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final meetingRepository = context.watch<MeetingRepository>();
    final currentUser =
        UserService(repository: context.watch<UserRepository>()).currentUser;

    final meetingService = MeetingService(repository: meetingRepository);
    final localService =
        LocalService(repository: context.read<LocalRepository>());

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Eventos')),
      body: _buildBody(context, meetingService, localService, currentUser),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MeetingService meetingService,
    LocalService localService,
    User? currentUser,
  ) {
    if (currentUser == null) {
      return const Center(
        child: Text('Faça login para ver seus eventos inscritos.'),
      );
    }

    return FutureBuilder<List<Meeting>>(
      future: meetingService.getSubscribedMeetings(user: currentUser),
      builder: (context, meetingSnapshot) {
        if (meetingSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (meetingSnapshot.hasError) {
          return const Center(child: Text('Erro ao carregar seus eventos.'));
        }
        final myMeetings = meetingSnapshot.data ?? [];
        if (myMeetings.isEmpty) {
          return _buildEmptyState(context);
        }
        return _buildMeetingsList(context, myMeetings);
      },
    );
  }

  Widget _buildMeetingsList(BuildContext context, List<Meeting> meetings) {
    final localService =
        LocalService(repository: context.read<LocalRepository>());

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];

        return FutureBuilder<Local?>(
          future: localService.getLocalById(meeting.localId),
          builder: (context, localSnapshot) {
            final localName = localSnapshot.data?.name ?? 'Carregando local...';
            final bool isLoadingLocal =
                localSnapshot.connectionState == ConnectionState.waiting;

            return MeetingCard(
              meeting: meeting,
              localName: localName,
              isSubscribed: true,
              onSeeMorePressed: isLoadingLocal
                  ? () {}
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              MeetingDetailsPage(meeting: meeting),
                        ),
                      );
                    },
              onSubscribePressed: () {},
            );
          },
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
