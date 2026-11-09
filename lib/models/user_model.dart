import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles disponibles para los usuarios en ConfirmaU.
enum UserRole {
  estudiante('estudiante', 'Estudiante'),
  docente('docente', 'Docente');

  final String value;
  final String label;

  const UserRole(this.value, this.label);

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.estudiante;
    final normalized = role.toLowerCase().trim();
    if (normalized == 'docente' ||
        normalized == 'profesor' ||
        normalized == 'teacher') {
      return UserRole.docente;
    }
    return UserRole.estudiante;
  }
}

/// Modelo de datos para los usuarios en Firestore.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String code;
  final UserRole role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.code,
    required this.role,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// Crea una copia de este modelo con los campos especificados actualizados.
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? code,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      code: code ?? this.code,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convierte la instancia en un mapa serializable para Cloud Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'code': code,
      'role': role.value,
      'isActive': isActive,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Crea una instancia a partir de un mapa de Firestore.
  factory UserModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return UserModel(
      uid: uid ?? map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      code: map['code'] as String? ?? '',
      role: UserRole.fromString(map['role'] as String?),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  /// Crea una instancia a partir de un DocumentSnapshot de Firestore.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return UserModel.fromMap(data, uid: doc.id);
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, name: $name, email: $email, code: $code, role: ${role.value})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.uid == uid &&
        other.name == name &&
        other.email == email &&
        other.code == code &&
        other.role == role;
  }

  @override
  int get hashCode =>
      uid.hashCode ^
      name.hashCode ^
      email.hashCode ^
      code.hashCode ^
      role.hashCode;
}

