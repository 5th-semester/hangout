import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/meeting.dart';
import 'package:hangout/models/user.dart';
import 'package:hangout/models/local.dart';
import 'package:hangout/repositories/local_repository.dart';
import '../services/meeting_service.dart';
import '../services/user_service.dart';
import '../services/local_service.dart';
import '../repositories/meeting_repository.dart';
import '../repositories/user_repository.dart';
import 'meeting_settings.dart';

class MeetingDetailsPage extends StatefulWidget {
  final Meeting meeting;

  const MeetingDetailsPage({super.key, required this.meeting});

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  void _handleSubscription(
    Meeting meeting,
    User? currentUser,
    bool isSubscribed,
  ) {
    final meetingRepo = MeetingService(
      repository: context.read<MeetingRepository>(),
    );

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado para esta ação.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isSubscribed) {
      meetingRepo.unsubscribeFromMeeting(meeting: meeting, user: currentUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inscrição em "${meeting.name}" cancelada.'),
          backgroundColor: Colors.grey,
        ),
      );
    } else {
      meetingRepo.subscribeToMeeting(meeting: meeting, user: currentUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inscrição em "${meeting.name}" realizada!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meetingRepository = context.read<MeetingRepository>();
    final meetingService = MeetingService(repository: meetingRepository);
    final currentUser = UserService(repository: context.read<UserRepository>())
        .currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meeting.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<Meeting?>(
        stream: meetingService.getMeetingStreamById(widget.meeting.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Erro ao carregar o evento.'));
          }

          final meeting = snapshot.data!;
          final isSubscribed =
              meetingService.isUserSubscribed(meeting: meeting, user: currentUser);
          final participantCount = meeting.userIds.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(context, meeting),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Descrição'),
                const SizedBox(height: 8),
                Text(
                  meeting.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  context,
                  'Participantes ($participantCount/5)',
                ),
                const SizedBox(height: 12),
                _buildParticipantsList(context, meeting.userIds),
              ],
            ),
          );
        },
      ),
      floatingActionButton: StreamBuilder<Meeting?>(
        stream: meetingService.getMeetingStreamById(widget.meeting.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }
          final meeting = snapshot.data!;
          final isSubscribed =
              meetingService.isUserSubscribed(meeting: meeting, user: currentUser);
          return _buildActionButton(meeting, currentUser, isSubscribed);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoCard(BuildContext context, Meeting meeting) {
    final localService = LocalService(repository: context.read<LocalRepository>());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(
              context,
              Icons.calendar_today_outlined,
              DateFormat(
                "EEEE, dd 'de' MMMM",
                'pt_BR',
              ).format(meeting.datetime),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              Icons.access_time_outlined,
              'Às ${DateFormat("HH:mm", 'pt_BR').format(meeting.datetime)}h',
            ),
            const SizedBox(height: 12),
            FutureBuilder<Local?>(
              future: localService.getLocalById(meeting.localId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildInfoRow(
                    context,
                    Icons.location_on_outlined,
                    'Carregando local...',
                  );
                }
                final localName = snapshot.data?.name ?? 'Local não encontrado';
                return _buildInfoRow(
                  context,
                  Icons.location_on_outlined,
                  localName,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildParticipantsList(BuildContext context, List<String> userIds) {
    final userRepository = context.read<UserRepository>();

    if (userIds.isEmpty) {
      return const Text('Ninguém se inscreveu ainda. Seja o primeiro!');
    }

    return FutureBuilder<List<User>>(
      future: userRepository.getUsersFromIds(userIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Text('Erro ao carregar participantes.');
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return const Text(
            'Não foi possível encontrar os dados dos participantes.',
          );
        }

        final users = snapshot.data!;

        return Column(
          children: users
              .map(
                (user) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name.substring(0, 1).toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(
                    user.name.isNotEmpty ? user.name : 'Usuário sem nome',
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildActionButton(
    Meeting meeting,
    User? currentUser,
    bool isSubscribed,
  ) {
    final bool isFull = meeting.userIds.length >= 5;

    if (meeting.creatorId == currentUser?.uid) {
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => MeetingSettings(meeting: meeting)),
          );
        },
        label: const Text('Editar encontro'),
        icon: const Icon(Icons.settings),
        backgroundColor: Colors.grey,
      );
    }

    if (isSubscribed) {
      return FloatingActionButton.extended(
        onPressed: () =>
            _handleSubscription(meeting, currentUser, isSubscribed),
        label: const Text('Cancelar Inscrição'),
        icon: const Icon(Icons.close),
        backgroundColor: Colors.grey[700],
      );
    }
    if (isFull) {
      return FloatingActionButton.extended(
        onPressed: null,
        label: const Text('Lotado'),
        icon: const Icon(Icons.block),
        backgroundColor: Colors.grey,
      );
    }
    return FloatingActionButton.extended(
      onPressed: () => _handleSubscription(meeting, currentUser, isSubscribed),
      label: const Text('Participar do Evento'),
      icon: const Icon(Icons.person_add_alt_1),
    );
  }
}
