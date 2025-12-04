import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../repositories/local_repository.dart';
import '../services/cep_service.dart';
import '../services/geocoding_service.dart';
import '../models/coordinates.dart';
import '../utils/geolocation_utils.dart';

class CreateLocalPage extends StatefulWidget {
  const CreateLocalPage({super.key});

  @override
  State<CreateLocalPage> createState() => _CreateLocalPageState();
}

class _CreateLocalPageState extends State<CreateLocalPage> {
  final _formKey = GlobalKey<FormState>();

  final _cepController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _streetController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();

  Coordinates? _coordinatesToSave;
  String _locationStatus = 'Nenhuma localização definida';

  bool _isLoading = false;
  bool _isSearchingCep = false;

  final _cepMask = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _cepController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _streetController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _searchCep() async {
    final cep = _cepController.text;
    if (cep.isEmpty || cep.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, digite um CEP válido.')),
      );
      return;
    }

    setState(() {
      _isSearchingCep = true;
      _locationStatus = 'Buscando endereço e coordenadas...';
    });

    final addressData = await CepService.fetchAddress(cep);

    if (addressData != null) {
      _streetController.text = addressData['logradouro'] ?? '';
      _districtController.text = addressData['bairro'] ?? '';
      _cityController.text =
          '${addressData['localidade']} - ${addressData['uf']}';

      if (_descriptionController.text.isEmpty) {
        _descriptionController.text =
            '${addressData['logradouro']}, ${addressData['bairro']}';
      }

      final foundCoordinates = await GeocodingService.getCoordinatesFromAddress(
        addressData['logradouro'] ?? '',
        addressData['localidade'] ?? '',
        addressData['uf'] ?? '',
      );

      setState(() {
        if (foundCoordinates != null) {
          _coordinatesToSave = foundCoordinates;
          _locationStatus = 'Localização encontrada pelo Endereço!';
        } else {
          _locationStatus = 'Endereço achado, mas coordenadas não. Use o GPS.';
        }
        _isSearchingCep = false;
      });
    } else {
      setState(() {
        _isSearchingCep = false;
        _locationStatus = 'CEP não encontrado.';
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('CEP não encontrado.')));
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locationStatus = 'Buscando GPS...');
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationStatus = 'Serviço de localização desabilitado');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Ative o GPS nas configurações.'),
              action: SnackBarAction(
                label: 'Abrir',
                onPressed: () => Geolocator.openLocationSettings(),
              ),
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() => _locationStatus = 'Permissão de localização negada');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permissão negada para acessar GPS.')),
          );
        }
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _locationStatus = 'Permissão negada permanentemente');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Permissão negada permanentemente. Ative nas configurações.'),
              action: SnackBarAction(
                label: 'Abrir',
                onPressed: () => Geolocator.openAppSettings(),
              ),
            ),
          );
        }
        return;
      }

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 10),
        );
      } on TimeoutException {
        Position? last;
        if (!kIsWeb) {
          last = await Geolocator.getLastKnownPosition();
        } else {
          last = null;
        }
        if (last != null) {
          position = last;
          setState(() => _locationStatus = 'Usando última posição conhecida (timeout).');
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tempo esgotado ao obter GPS.')));
          setState(() => _locationStatus = 'Erro ao obter GPS (timeout)');
          return;
        }
      }

      setState(() {
        _coordinatesToSave = Coordinates(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _locationStatus = 'Usando sua localização GPS atual';
      });
    } catch (e) {
      Position? last;
      if (!kIsWeb) {
        last = await Geolocator.getLastKnownPosition();
      } else {
        last = null;
      }
      if (last != null) {
        final lastPos = last;
        setState(() {
          _coordinatesToSave = Coordinates(
            latitude: lastPos.latitude,
            longitude: lastPos.longitude,
          );
          _locationStatus = 'Usando última posição conhecida (erro ao obter atual).';
        });
      } else {
        print("=============================================");
        print("Erro ao obter localização GPS: $e");
        print("=============================================");
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao obter localização GPS.')));
        setState(() => _locationStatus = 'Erro ao obter GPS');
      }
    }
  }

  Future<void> _saveLocal() async {
    if (!_formKey.currentState!.validate()) return;

    if (_coordinatesToSave == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Precisamos de uma localização (CEP ou GPS) para salvar.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (!mounted) return;

      final localRepo = context.read<LocalRepository>();

      await localRepo.createLocal(
        name: _nameController.text,
        description: _descriptionController.text,
        coordinates: _coordinatesToSave!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Local adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar local.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Novo Local')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cepController,
                      inputFormatters: [_cepMask],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'CEP',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map),
                        helperText: 'Preenche endereço e coordenadas',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isSearchingCep ? null : _searchCep,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    child: _isSearchingCep
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Local (ex: Casa do João)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Cidade/UF',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _streetController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Logradouro',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _districtController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Bairro',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descrição Completa',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      _locationStatus,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (_coordinatesToSave != null)
                      Text(
                        'Lat: ${_coordinatesToSave!.latitude.toStringAsFixed(4)}, '
                        'Lng: ${_coordinatesToSave!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (shouldShowGpsOption())
                OutlinedButton.icon(
                  onPressed: _useCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Usar meu GPS Atual em vez do CEP'),
                )
              else

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveLocal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Salvar Local'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
