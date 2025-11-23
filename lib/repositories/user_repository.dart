import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/user.dart';

class UserRepository with ChangeNotifier {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  late final CollectionReference _usersCollection;

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  UserRepository({
    fb_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance {
    _usersCollection = _firestore.collection('users');
    _init();
  }

  void _init() {
    _firebaseAuth.authStateChanges().listen((fb_auth.User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      } else {
        try {
          final user = await _getUserData(firebaseUser.uid);
          _currentUser = user;
        } catch (e) {
          _currentUser = null;
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      }
    });
  }

  Future<void> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        throw Exception('Usuário ou senha inválidos.');
      }
      throw Exception('Ocorreu um erro no login.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String cpf,
    required String password,
  }) async {
    try {
      final unmaskedCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');

      final cpfQuery = await _usersCollection
          .where('cpf', isEqualTo: unmaskedCpf)
          .limit(1)
          .get();

      if (cpfQuery.docs.isNotEmpty) {
        throw Exception('Este CPF já está cadastrado.');
      }

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Não foi possível criar o usuário na autenticação.');
      }

      final newUser = User(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        cpf: unmaskedCpf,
      );

      await _usersCollection.doc(newUser.uid).set(newUser.toFirestore());
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Este email já está em uso.');
      }
      throw Exception('Ocorreu um erro ao criar a conta.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  Future<List<User>> getUsersFromIds(List<String> userIds) async {
    if (userIds.isEmpty) {
      return [];
    }

    final validIds = userIds.where((id) => id.isNotEmpty).toList();

    if (validIds.isEmpty) {
      return [];
    }

    try {
      final userDocs = await Future.wait(
        validIds.map((id) => _usersCollection.doc(id).get()),
      );

      final userList = userDocs
          .where((doc) => doc.exists)
          .map(
            (doc) => User.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();
      return userList;
    } catch (e) {
      return [];
    }
  }

  Future<User?> _getUserData(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return User.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou senha inválidos.';
      case 'email-already-in-use':
        return 'Este email já está em uso.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      case 'invalid-email':
        return 'O email fornecido não é válido.';
      default:
        return 'Erro de autenticação. Tente novamente.';
    }
  }
}
