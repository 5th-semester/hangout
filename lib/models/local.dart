import 'package:hangout/models/coordinates.dart';

class Local {
  final int local_id;
  final String name;
  final String description;
  final Coordinates coordinates;

  Local({
    required this.local_id,
    required this.name,
    required this.description,
    required this.coordinates,
  });
}
