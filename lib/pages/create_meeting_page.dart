import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importe o pacote de formatação
import '../models/local.dart';
import '../pickers/location_picker.dart';
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

  void _submitForm() {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (_selectedLocal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um local.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione data e hora.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isFormValid) {
      // TODO: Aqui você pegaria todos os dados e enviaria para o repositório
      print('Nome: ${_nameController.text}');
      print('Descrição: ${_descriptionController.text}');
      print('Local: ${_selectedLocal!.name}');
      print('Data/Hora: ${_selectedDateTime!}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento criado com sucesso!')),
      );
      Navigator.of(context).pop();
    }
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
