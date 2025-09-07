import 'dart:math';

import './mocks/meeting_mocks.dart';
import '../models/coordinates.dart';
import '../models/meeting.dart';

class _MeetingWithDistance {
  final Meeting meeting;
  final double distanceInKm;

  _MeetingWithDistance({required this.meeting, required this.distanceInKm});
}

class MeetingRepository {
  final List<Meeting> _allMeetings = MeetingMocks.list;

  List<Meeting> getPaginatedMeetingsByProximity({
    required Coordinates userCoordinates,
    required int itemsPerPage,
    int? lastMeetingId,
  }) {
    final meetingsWithDistance = _allMeetings.map((meeting) {
      final distance = _calculateDistanceInKm(
        userCoordinates,
        meeting.local.coordinates,
      );
      return _MeetingWithDistance(meeting: meeting, distanceInKm: distance);
    }).toList();

    meetingsWithDistance.sort(
      (a, b) => a.distanceInKm.compareTo(b.distanceInKm),
    );

    int startIndex = 0;

    if (lastMeetingId != null) {
      final lastIndex = meetingsWithDistance.indexWhere(
        (m) => m.meeting.meeting_id == lastMeetingId,
      );
      if (lastIndex != -1) {
        startIndex = lastIndex + 1;
      }
    }

    final paginatedList = meetingsWithDistance
        .skip(startIndex)
        .take(itemsPerPage)
        .map((m) => m.meeting)
        .toList();

    return paginatedList;
  }

  double _calculateDistanceInKm(Coordinates point1, Coordinates point2) {
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
}
