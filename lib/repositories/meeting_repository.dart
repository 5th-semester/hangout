import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coordinates.dart';
import '../models/meeting.dart';
import '../models/user.dart';
import '../models/local.dart';
import '../utils/geolocation_utils.dart';

class MeetingData {
  final Meeting meeting;
  final Local local;
  MeetingData({required this.meeting, required this.local});
}

class _MeetingWithDistance {
  final Meeting meeting;
  final Local local;
  final double distanceInKm;
  _MeetingWithDistance({
    required this.meeting,
    required this.local,
    required this.distanceInKm,
  });
}

class MeetingRepository with ChangeNotifier {
  final FirebaseFirestore _firestore;
  late final CollectionReference _meetingsCollection;
  late final CollectionReference _localsCollection;

  MeetingRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    _meetingsCollection = _firestore.collection('meetings');
    _localsCollection = _firestore.collection('locals');
  }

  Future<List<MeetingData>> getPaginatedMeetingsByProximity({
    required Coordinates userCoordinates,
    required int itemsPerPage,
    String? lastMeetingId,
  }) async {
    final meetingsSnapshot = await _meetingsCollection.get();
    final allMeetings = meetingsSnapshot.docs
        .map(
          (doc) => Meeting.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          ),
        )
        .toList();

    final meetingsWithDistance = await Future.wait(
      allMeetings.map((meeting) async {
        final localDoc = await _localsCollection.doc(meeting.localId).get();
        final local = Local.fromFirestore(
          localDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        final distance = calculateDistanceInKm(
          userCoordinates,
          local.coordinates,
        );
        return _MeetingWithDistance(
          meeting: meeting,
          local: local,
          distanceInKm: distance,
        );
      }),
    );

    meetingsWithDistance.sort(
      (a, b) => a.distanceInKm.compareTo(b.distanceInKm),
    );

    int startIndex = 0;
    if (lastMeetingId != null) {
      final lastIndex = meetingsWithDistance.indexWhere(
        (m) => m.meeting.id == lastMeetingId,
      );
      if (lastIndex != -1) {
        startIndex = lastIndex + 1;
      }
    }

    final paginatedList = meetingsWithDistance
        .skip(startIndex)
        .take(itemsPerPage)
        .map((m) => MeetingData(meeting: m.meeting, local: m.local))
        .toList();

    return paginatedList;
  }

  Future<List<Meeting>> getSubscribedMeetings({required User user}) async {
    final querySnapshot = await _meetingsCollection
        .where('userIds', arrayContains: user.uid)
        .orderBy('datetime')
        .get();

    final subscribedMeetings = querySnapshot.docs
        .map(
          (doc) => Meeting.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          ),
        )
        .toList();

    print(subscribedMeetings);

    return subscribedMeetings;
  }

  Future<Meeting?> getMeetingById(String id) async {
    try {
      final doc = await _meetingsCollection.doc(id).get();
      if (doc.exists) {
        return Meeting.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<Meeting?> getMeetingStreamById(String id) {
    return _meetingsCollection.doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return Meeting.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>,
        );
      }
      return null;
    });
  }

  Future<Meeting> createMeeting({
    required String name,
    required String description,
    required DateTime datetime,
    required Local local,
    required User creatorUser,
  }) async {
    final newMeetingData = {
      'name': name,
      'description': description,
      'datetime': Timestamp.fromDate(datetime),
      'localId': local.id,
      'userIds': [creatorUser.uid],
    };

    final docRef = await _meetingsCollection.add(newMeetingData);

    final newMeeting = Meeting(
      id: docRef.id,
      name: name,
      description: description,
      datetime: datetime,
      localId: local.id,
      userIds: [creatorUser.uid],
    );

    notifyListeners();
    return newMeeting;
  }

  Future<void> subscribeToMeeting({
    required Meeting meeting,
    required User user,
  }) async {
    final meetingRef = _meetingsCollection.doc(meeting.id);

    await meetingRef.update({
      'userIds': FieldValue.arrayUnion([user.uid]),
    });

    notifyListeners();
  }

  Future<void> unsubscribeFromMeeting({
    required Meeting meeting,
    required User user,
  }) async {
    final meetingRef = _meetingsCollection.doc(meeting.id);

    await meetingRef.update({
      'userIds': FieldValue.arrayRemove([user.uid]),
    });

    notifyListeners();
  }

  bool isUserSubscribed({required Meeting meeting, required User? user}) {
    if (user == null) return false;
    return meeting.userIds.any((id) => id == user.uid);
  }
}
