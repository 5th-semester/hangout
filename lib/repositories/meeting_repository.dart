import 'dart:math';
import 'package:flutter/foundation.dart';
import './mocks/meeting_mocks.dart';
import '../models/coordinates.dart';
import '../models/meeting.dart';
import '../models/user.dart';
import '../models/local.dart';

class _MeetingWithDistance {
  final Meeting meeting;
  final double distanceInKm;

  _MeetingWithDistance({required this.meeting, required this.distanceInKm});
}

class MeetingRepository with ChangeNotifier {
  final List<Meeting> _allMeetings = List.from(MeetingMocks.list);

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

  List<Meeting> getSubscribedMeetings({required User user}) {
    final subscribedMeetings = _allMeetings.where((meeting) {
      return meeting.users.any(
        (subscribedUser) => subscribedUser.user_id == user.user_id,
      );
    }).toList();

    subscribedMeetings.sort((a, b) => a.datetime.compareTo(b.datetime));

    return subscribedMeetings;
  }

  Future<void> createMeeting({
    required String name,
    required String description,
    required DateTime datetime,
    required Local local,
    required User creatorUser,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final newId = _allMeetings.isNotEmpty
        ? _allMeetings.map((m) => m.meeting_id).reduce(max) + 1
        : 1;
    final newMeeting = Meeting(
      meeting_id: newId,
      name: name,
      description: description,
      datetime: datetime,
      local: local,
      users: [creatorUser],
    );
    _allMeetings.add(newMeeting);
    print('✅ Encontro "${newMeeting.name}" criado com sucesso!');
    notifyListeners();
  }

  Future<void> subscribeToMeeting({
    required Meeting meeting,
    required User user,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final meetingToUpdate = _allMeetings.firstWhere(
      (m) => m.meeting_id == meeting.meeting_id,
    );

    final isAlreadySubscribed = meetingToUpdate.users.any(
      (u) => u.user_id == user.user_id,
    );

    if (!isAlreadySubscribed) {
      meetingToUpdate.users.add(user);
      print('✅ Usuário "${user.name}" inscrito em "${meeting.name}"');
      notifyListeners();
    } else {
      print(
        'ℹ️ Usuário "${user.name}" já estava inscrito em "${meeting.name}"',
      );
    }
  }

  bool isUserSubscribed({required Meeting meeting, required User? user}) {
    if (user == null) return false;
    return meeting.users.any((u) => u.user_id == user.user_id);
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
