import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // NOVO: Importação para formatar a data
import '../models/meeting.dart';

class MeetingCard extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback onSubscribePressed;
  final VoidCallback onSeeMorePressed;

  const MeetingCard({
    super.key,
    required this.meeting,
    required this.onSubscribePressed,
    required this.onSeeMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onSeeMorePressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildDescription(),
              const SizedBox(height: 16),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meeting.name,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8), // Aumentei um pouco o espaço
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              meeting.local.name,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // NOVO: Widget para exibir a data e a hora
        Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              // Usamos DateFormat para um visual limpo e localizado
              DateFormat(
                "E, dd/MMM 'às' HH:mm",
                'pt_BR',
              ).format(meeting.datetime),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    // ... sem alterações aqui
    return Text(
      meeting.description,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: Colors.grey[800]),
    );
  }

  Widget _buildFooter(BuildContext context) {
    // ... sem alterações aqui
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildParticipantCountChip(context), _buildActionButtons()],
    );
  }

  Widget _buildParticipantCountChip(BuildContext context) {
    // ... sem alterações aqui
    final isFull = meeting.users.length >= 5;
    return Chip(
      avatar: Icon(
        Icons.people_outline,
        size: 18,
        color: isFull ? Colors.red : Theme.of(context).primaryColor,
      ),
      label: Text(
        '${meeting.users.length} / 5 inscritos',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      side: BorderSide.none,
    );
  }

  Widget _buildActionButtons() {
    // ... sem alterações aqui
    final isFull = meeting.users.length >= 5;

    return Row(
      children: [
        TextButton(onPressed: onSeeMorePressed, child: const Text('Ver Mais')),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: isFull ? null : onSubscribePressed,
          child: const Text('Participar'),
        ),
      ],
    );
  }
}
