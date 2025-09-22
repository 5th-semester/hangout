import 'dart:math';
import '../models/coordinates.dart';

double calculateDistanceInKm(Coordinates point1, Coordinates point2) {
  const earthRadiusKm = 6371;

  final dLat = _degreesToRadians(point2.latitude - point1.latitude);
  final dLon = _degreesToRadians(point2.longitude - point1.longitude);

  final lat1 = _degreesToRadians(point1.latitude);
  final lat2 = _degreesToRadians(point2.latitude);

  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadiusKm * c;
}

double _degreesToRadians(double degrees) {
  return degrees * pi / 180;
}
