import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

/// Servicio para operaciones CRUD de usuarios en Cloud Firestore.
///
/// Centraliza la interacción con la colección 'users'.
class UserService {
  UserService._();

  static final UserService instance = UserService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Referencia a la colección 'users' tipada con [UserModel] usando `withConverter`.
  CollectionReference<UserModel> get _usersRef =>
      _firestore.collection('users').withConverter<UserModel>(
            fromFirestore: (snapshot, _) => UserModel.fromFirestore(snapshot),
            toFirestore: (user, _) => user.toMap(),
          );

  /// Guarda o actualiza los datos del usuario en Firestore.
  /// Utiliza el UID de Firebase Auth como ID del documento.
  Future<void> saveUser(UserModel user) async {
    await _usersRef.doc(user.uid).set(user, SetOptions(merge: true));
  }

  /// Obtiene los datos de un usuario por su [uid].
  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    return doc.data();
  }

  /// Stream para escuchar los cambios en tiempo real del documento del usuario.
  Stream<UserModel?> streamUser(String uid) {
    return _usersRef.doc(uid).snapshots().map((snapshot) => snapshot.data());
  }

  /// Verifica si existe un perfil de usuario registrado para el [uid].
  Future<bool> userExists(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    return doc.exists;
  }
}

