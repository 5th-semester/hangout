import 'package:cloud_firestore/cloud_firestore.dart';

class Meeting {
  final String id;
  final String name;
  final String description;
  final String localId;
  final List<String> userIds;
  final DateTime datetime;

  Meeting({
    required this.id,
    required this.name,
    required this.description,
    required this.localId,
    required this.userIds,
    required this.datetime,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'localId': localId,
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
      userIds: List<String>.from(data['userIds'] ?? []),
      datetime: (data['datetime'] as Timestamp).toDate(),
    );
  }
}
