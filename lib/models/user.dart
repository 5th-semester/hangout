import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String name;
  final String email;
  final String cpf;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.cpf,
  });

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'email': email, 'cpf': cpf};
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      cpf: data['cpf'] ?? '',
    );
  }
}
