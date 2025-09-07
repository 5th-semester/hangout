import './mocks/local_mocks.dart';
import '../models/coordinates.dart';
import '../models/local.dart';
import '../utils/geolocation_utils.dart';

class _LocalWithDistance {
  final Local local;
  final double distanceInKm;

  _LocalWithDistance({required this.local, required this.distanceInKm});
}

class LocalRepository {
  final List<Local> _allLocals = LocalMocks.list;

  List<Local> getClosestLocals({
    required Coordinates userCoordinates,
    int limit = 5,
  }) {
    final localsWithDistance = _allLocals.map((local) {
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
}
