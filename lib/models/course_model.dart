import 'package:cloud_firestore/cloud_firestore.dart';

enum CourseStatus { enCurso, proxima, finalizada }

class CourseModel {
  CourseModel({
    this.id = '',
    required this.teacherId,
    required this.name,
    required this.code,
    required this.schedule,
    required this.room,
    required this.method,
    required this.minutes,
    this.startDate,
    this.endDate,
    this.studentEmails = const [],
  });

  final String id;
  final String teacherId;
  final String name;
  final String code;
  final String schedule;
  final String room;

  /// 'ble' | 'challenge' | 'double'
  final String method;
  final int minutes;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> studentEmails;

  int get studentCount => studentEmails.length;

  String get methodLabel {
    switch (method) {
      case 'ble':
        return 'Proximidad';
      case 'challenge':
        return 'Reto';
      case 'double':
        return 'Doble';
      default:
        return 'Metodo Desconocido';
    }
  }

  CourseStatus get status {
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!))
      return CourseStatus.proxima;
    if (endDate != null && now.isAfter(endDate!.add(const Duration(days: 1)))) {
      return CourseStatus.finalizada;
    }
    return CourseStatus.enCurso;
  }

  factory CourseModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return CourseModel(
      id: d.id,
      teacherId: (m['teacherId'] ?? '') as String,
      name: (m['name'] ?? '') as String,
      code: (m['code'] ?? '') as String,
      schedule: (m['schedule'] ?? '') as String,
      room: (m['room'] ?? '') as String,
      method: (m['method'] ?? 'double') as String,
      minutes: (m['minutes'] ?? 5) as int,
      startDate: (m['startDate'] as Timestamp?)?.toDate(),
      endDate: (m['endDate'] as Timestamp?)?.toDate(),
      studentEmails: List<String>.from(m['studentEmails'] ?? const []),
    );
  }

  Map<String, dynamic> toMap() => {
    'teacherId': teacherId,
    'name': name,
    'code': code,
    'schedule': schedule,
    'room': room,
    'method': method,
    'minutes': minutes,
    'startDate': startDate == null ? null : Timestamp.fromDate(startDate!),
    'endDate': endDate == null ? null : Timestamp.fromDate(endDate!),
    'studentEmails': studentEmails,
  };
}
