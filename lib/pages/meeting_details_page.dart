import 'package:flutter/material.dart';
import 'package:hangout/models/user.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/meeting.dart';
import '../repositories/meeting_repository.dart';
import '../repositories/user_repository.dart';

class MeetingDetailsPage extends StatefulWidget {
  final Meeting meeting;

  const MeetingDetailsPage({super.key, required this.meeting});

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  late bool _isSubscribed;
  late bool _isFull;

  @override
  void initState() {
    super.initState();
    final meetingRepo = context.read<MeetingRepository>();
    final currentUser = context.read<UserRepository>().currentUser;
    _isSubscribed = meetingRepo.isUserSubscribed(
      meeting: widget.meeting,
      user: currentUser,
    );
    _isFull = widget.meeting.users.length >= 5;
  }

  void _handleSubscription() {
    final meetingRepo = context.read<MeetingRepository>();
    final currentUser = context.read<UserRepository>().currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado para se inscrever.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    meetingRepo.subscribeToMeeting(meeting: widget.meeting, user: currentUser);

    // Atualiza o estado localmente para feedback instantâneo na UI
    setState(() {
      _isSubscribed = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inscrição em "${widget.meeting.name}" realizada!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuta por mudanças para atualizar o número de participantes
    final meeting =
        context.watch<MeetingRepository>().getMeetingById(
          widget.meeting.meeting_id,
        ) ??
        widget.meeting;
    _isFull = meeting.users.length >= 5;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meeting.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Descrição'),
            const SizedBox(height: 8),
            Text(
              widget.meeting.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(
              context,
              'Participantes (${meeting.users.length}/5)',
            ),
            const SizedBox(height: 12),
            _buildParticipantsList(meeting.users),
          ],
        ),
      ),
      floatingActionButton: _buildActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoCard(BuildContext context) {
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
              ).format(widget.meeting.datetime),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              Icons.access_time_outlined,
              'Às ${DateFormat("HH:mm", 'pt_BR').format(widget.meeting.datetime)}h',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              Icons.location_on_outlined,
              widget.meeting.local.name,
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

  Widget _buildParticipantsList(List<User> users) {
    if (users.isEmpty) {
      return const Text('Ninguém se inscreveu ainda. Seja o primeiro!');
    }
    return Column(
      children: users
          .map(
            (user) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColorLight,
                child: Text(user.name.substring(0, 1).toUpperCase()),
              ),
              title: Text(user.name),
            ),
          )
          .toList(),
    );
  }

  Widget _buildActionButton() {
    if (_isSubscribed) {
      return FloatingActionButton.extended(
        onPressed: null,
        label: const Text('Inscrito'),
        icon: const Icon(Icons.check_circle_outline),
        backgroundColor: Colors.green,
      );
    }
    if (_isFull) {
      return FloatingActionButton.extended(
        onPressed: null,
        label: const Text('Lotado'),
        icon: const Icon(Icons.block),
        backgroundColor: Colors.grey,
      );
    }
    return FloatingActionButton.extended(
      onPressed: _handleSubscription,
      label: const Text('Participar do Evento'),
      icon: const Icon(Icons.person_add_alt_1),
    );
  }
}
