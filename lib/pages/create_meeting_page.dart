import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hangout/repositories/user_repository.dart';
import 'package:hangout/repositories/meeting_repository.dart';
import '../models/local.dart';
import '../pickers/location_picker.dart';
import '../models/user.dart';
import '../pickers/date_time_picker.dart';
import '../widgets/custom_picker_tile.dart';

class CreateMeetingPage extends StatefulWidget {
  const CreateMeetingPage({super.key});

  @override
  State<CreateMeetingPage> createState() => _CreateMeetingPageState();
}

class _CreateMeetingPageState extends State<CreateMeetingPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  Local? _selectedLocal;
  DateTime? _selectedDateTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
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

  bool _validateInputs() {
    if (_selectedLocal == null) {
      _showErrorSnackBar('Por favor, selecione um local.');
      return false;
    }
    if (_selectedDateTime == null) {
      _showErrorSnackBar('Por favor, selecione data e hora.');
      return false;
    }

    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      return false;
    }
    return true;
  }

  Future<void> _submitForm() async {
    if (!_validateInputs()) return;

    final currentUser = context.read<UserRepository>().currentUser;
    if (currentUser == null) {
      _showErrorSnackBar('Erro: Nenhum usuário logado. Faça login novamente.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _createMeeting(currentUser);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento criado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      _showErrorSnackBar('Ocorreu um erro ao criar o evento: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createMeeting(User currentUser) {
    final meetingRepository = context.read<MeetingRepository>();
    return meetingRepository.createMeeting(
      name: _nameController.text,
      description: _descriptionController.text,
      datetime: _selectedDateTime!,
      local: _selectedLocal!,
      creatorUser: currentUser,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Novo Evento')),
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
                valueText: _selectedLocal?.name ?? '',
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
                onPressed: _submitForm,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Salvar Evento'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
