import '../repositories/meeting_repository.dart';
import '../models/meeting.dart';
import '../models/local.dart';
import '../models/user.dart';
import '../models/coordinates.dart';

class MeetingService {
  final MeetingRepository repository;

  MeetingService({required this.repository});

  Future<List<MeetingData>> getPaginatedMeetingsByProximity({
    required Coordinates userCoordinates,
    required int itemsPerPage,
    String? lastMeetingId,
  }) =>
      repository.getPaginatedMeetingsByProximity(
        userCoordinates: userCoordinates,
        itemsPerPage: itemsPerPage,
        lastMeetingId: lastMeetingId,
      );

  Future<List<Meeting>> getSubscribedMeetings({required User user}) =>
      repository.getSubscribedMeetings(user: user);

  Future<Meeting?> getMeetingById(String id) => repository.getMeetingById(id);

  Stream<Meeting?> getMeetingStreamById(String id) =>
      repository.getMeetingStreamById(id);

  Future<Meeting> createMeeting({
    required String name,
    required String description,
    required DateTime datetime,
    required Local local,
    required User creatorUser,
  }) =>
      repository.createMeeting(
        name: name,
        description: description,
        datetime: datetime,
        local: local,
        creatorUser: creatorUser,
      );

  Future<void> subscribeToMeeting({required Meeting meeting, required User user}) =>
      repository.subscribeToMeeting(meeting: meeting, user: user);

  Future<void> unsubscribeFromMeeting({required Meeting meeting, required User user}) =>
      repository.unsubscribeFromMeeting(meeting: meeting, user: user);

  bool isUserSubscribed({required Meeting meeting, required User? user}) =>
      repository.isUserSubscribed(meeting: meeting, user: user);

  Future<void> updateMeetingData({
    required String meetingId,
    required Map<String, dynamic> data,
  }) =>
      repository.updateMeetingData(meetingId: meetingId, data: data);

  Future<void> deleteMeeting(String meetingId) =>
      repository.deleteMeeting(meetingId);
}
