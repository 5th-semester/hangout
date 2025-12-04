import 'package:flutter/material.dart';
import '../models/coordinates.dart';
import '../models/local.dart';
import '../repositories/local_repository.dart';
import '../widgets/location_picker_sheet.dart';

Future<Local?> showLocationPicker(BuildContext context) async {
  final localRepository = LocalRepository();
  final userLocation = Coordinates(latitude: -25.095, longitude: -50.162);

  bool dialogShown = false;
  List<Local> nearbyLocals = [];

  try {
    dialogShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    nearbyLocals = await localRepository.getClosestLocals(
      userCoordinates: userLocation,
      limit: 7,
    );
  } catch (e) {
    // Ensure dialog is dismissed and inform the user
    if (dialogShown && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      dialogShown = false;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro ao buscar locais próximos.')),
    );
    return null;
  }

  if (dialogShown && Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }

  final selectedLocal = await showModalBottomSheet<Local>(
    context: context,
    builder: (BuildContext context) {
      return LocationPickerSheet(locals: nearbyLocals);
    },
  );

  return selectedLocal;
}
