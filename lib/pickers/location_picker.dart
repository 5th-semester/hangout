import 'package:flutter/material.dart';
import '../models/coordinates.dart';
import '../models/local.dart';
import '../repositories/local_repository.dart';
import '../widgets/location_picker_sheet.dart';

Future<Local?> showLocationPicker(BuildContext context) async {
  final localRepository = LocalRepository();
  final userLocation = Coordinates(latitude: -25.095, longitude: -50.162);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  final nearbyLocals = localRepository.getClosestLocals(
    userCoordinates: userLocation,
    limit: 7,
  );

  Navigator.of(context).pop();

  final selectedLocal = await showModalBottomSheet<Local>(
    context: context,
    builder: (BuildContext context) {
      return LocationPickerSheet(locals: nearbyLocals);
    },
  );

  return selectedLocal;
}
