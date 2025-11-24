import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String name;
  final String email;
  final String cpf;
  final String bio; // novo
  final String photoUrl; // novo

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.cpf,
    this.bio = '',
    this.photoUrl = '',
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'cpf': cpf,
      'bio': bio,
      'photoUrl': photoUrl,
    };
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      cpf: data['cpf'] ?? '',
      bio: data['bio'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }
}
