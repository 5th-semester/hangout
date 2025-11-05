import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hangout/models/coordinates.dart';

class Local {
  final String id;
  final String name;
  final String description;
  final Coordinates coordinates;

  Local({
    required this.id,
    required this.name,
    required this.description,
    required this.coordinates,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'coordinates': {
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
      },
    };
  }

  factory Local.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    final coordinatesMap = data['coordinates'] as Map<String, dynamic>? ?? {};

    return Local(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      coordinates: Coordinates(
        latitude: coordinatesMap['latitude'] ?? 0.0,
        longitude: coordinatesMap['longitude'] ?? 0.0,
      ),
    );
  }
}
