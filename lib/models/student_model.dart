import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  StudentModel({
    this.id = '',
    required this.name,
    required this.program,
    required this.code,
    required this.email,
    this.document = '',
    this.phone = '',
  });

  final String id;
  final String name;
  final String program;
  final String code;
  final String email;
  final String document;
  final String phone;

  factory StudentModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return StudentModel(
      id: d.id,
      name: (m['name'] ?? '') as String,
      program: (m['program'] ?? '') as String,
      code: (m['code'] ?? '') as String,
      email: (m['email'] ?? '') as String,
      document: (m['document'] ?? '') as String,
      phone: (m['phone'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'program': program,
    'code': code,
    'email': email.toLowerCase(),
    'document': document,
    'phone': phone,
  };
}
