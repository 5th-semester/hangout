import 'package:flutter/material.dart';
import 'package:hangout/models/meeting.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hangout/repositories/local_repository.dart';
import 'package:hangout/repositories/meeting_repository.dart';
import '../models/local.dart';
import '../pickers/location_picker.dart';
import '../pickers/date_time_picker.dart';
import '../widgets/custom_picker_tile.dart';
import '../services/meeting_service.dart';

class MeetingSettings extends StatefulWidget {
  final Meeting meeting;
  const MeetingSettings({super.key, required this.meeting});

  @override
  State<MeetingSettings> createState() => _MeetingSettingsState();
}

class _MeetingSettingsState extends State<MeetingSettings> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  Local? _selectedLocal;
  DateTime? _selectedDateTime;
  bool _isLoading = false;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.meeting.name);
    _descriptionController =
        TextEditingController(text: widget.meeting.description);
    _selectedDateTime = widget.meeting.datetime;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      _loadInitialLocal();
      _isDataLoaded = true;
    }
  }

  Future<void> _loadInitialLocal() async {
    final localRepo = context.read<LocalRepository>();
    final local = await localRepo.getLocalById(widget.meeting.localId);
    if (mounted) {
      setState(() {
        _selectedLocal = local;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await showLocationPicker(context);
    if (result != null) {
      setState(() {
        _selectedLocal = result;
      });
    }
  }

  Future<void> _pickDateTime() async {
    final result = await showDateTimePicker(context);
    if (result != null) {
      setState(() {
        _selectedDateTime = result;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _submitForm(Meeting meeting) async {
    if (_selectedLocal == null) {
      _showErrorSnackBar('Por favor, selecione um local.');
      return;
    }
    if (_selectedDateTime == null) {
      _showErrorSnackBar('Por favor, selecione data e hora.');
      return;
    }

    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _updateMeeting(meeting);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      _showErrorSnackBar('Ocorreu um erro ao atualizar o evento: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateMeeting(Meeting meeting) {
    final meetingService = MeetingService(
      repository: context.read<MeetingRepository>(),
    );

    final Map<String, dynamic> dataToUpdate = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'datetime': Timestamp.fromDate(_selectedDateTime!),
      'localId': _selectedLocal!.id,
    };

    return meetingService.updateMeetingData(
      meetingId: meeting.id,
      data: dataToUpdate,
    );
  }

  void _showDeleteConfirmation() {
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
            'Tem certeza que deseja excluir este evento? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteMeeting();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMeeting() async {
    setState(() => _isLoading = true);
    try {
      final meetingService = MeetingService(
        repository: context.read<MeetingRepository>(),
      );
      await meetingService.deleteMeeting(widget.meeting.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento excluído com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      _showErrorSnackBar('Erro ao excluir o evento: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Evento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Evento',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Por favor, insira um nome.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Por favor, insira uma descrição.'
                    : null,
              ),
              const SizedBox(height: 24),
              CustomPickerTile(
                label: 'Selecionar Local',
                valueText: _selectedLocal?.name ?? 'Carregando local...',
                icon: Icons.location_on_outlined,
                onTap: _pickLocation,
              ),
              const SizedBox(height: 16),
              CustomPickerTile(
                label: 'Selecionar Data e Hora',
                valueText: _selectedDateTime == null
                    ? ''
                    : DateFormat(
                        "EEEE, d 'de' MMMM 'de' y - HH:mm",
                        'pt_BR',
                      ).format(_selectedDateTime!),
                icon: Icons.calendar_today_outlined,
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _submitForm(widget.meeting),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(_isLoading ? 'Salvando...' : 'Atualizar Evento'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _showDeleteConfirmation,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Excluir Evento'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Theme.of(context).colorScheme.error,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}