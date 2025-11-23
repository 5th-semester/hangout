import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coordinates.dart';
import '../models/local.dart';
import '../utils/geolocation_utils.dart';

class _LocalWithDistance {
  final Local local;
  final double distanceInKm;
  _LocalWithDistance({required this.local, required this.distanceInKm});
}

class LocalRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference _localsCollection;

  LocalRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    _localsCollection = _firestore.collection('locals');
  }

  Future<Local?> getLocalById(String id) async {
    try {
      final doc = await _localsCollection.doc(id).get();
      if (doc.exists) {
        return Local.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Local>> getClosestLocals({
    required Coordinates userCoordinates,
    int limit = 5,
  }) async {
    final localsSnapshot = await _localsCollection.get();
    final allLocals = localsSnapshot.docs
        .map(
          (doc) => Local.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          ),
        )
        .toList();

    final localsWithDistance = allLocals.map((local) {
      final distance = calculateDistanceInKm(
        userCoordinates,
        local.coordinates,
      );
      return _LocalWithDistance(local: local, distanceInKm: distance);
    }).toList();

    localsWithDistance.sort((a, b) => a.distanceInKm.compareTo(b.distanceInKm));

    final closestLocals = localsWithDistance
        .take(limit)
        .map((l) => l.local)
        .toList();

    return closestLocals;
  }

  Future<Local> createLocal({
    required String name,
    required String description,
    required Coordinates coordinates,
  }) async {
    final newLocalData = {
      'name': name,
      'description': description,
      'coordinates': {
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
      },
    };

    final docRef = await _localsCollection.add(newLocalData);

    return Local(
      id: docRef.id,
      name: name,
      description: description,
      coordinates: coordinates,
    );
  }
}
