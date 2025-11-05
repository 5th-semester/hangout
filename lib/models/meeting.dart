import 'package:cloud_firestore/cloud_firestore.dart';

class Meeting {
  final String id;
  final String name;
  final String description;
  final String localId;
  final String creatorId;
  final List<String> userIds;
  final DateTime datetime;

  Meeting({
    required this.id,
    required this.name,
    required this.description,
    required this.localId,
    required this.creatorId,
    required this.userIds,
    required this.datetime,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'localId': localId,
      'creatorId': creatorId,
      'userIds': userIds,
      'datetime': Timestamp.fromDate(datetime),
    };
  }

  factory Meeting.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return Meeting(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      localId: data['localId'] ?? '',
      creatorId: data['creatorId'] ?? '',
      userIds: List<String>.from(data['userIds'] ?? []),
      datetime: (data['datetime'] as Timestamp).toDate(),
    );
  }
}
