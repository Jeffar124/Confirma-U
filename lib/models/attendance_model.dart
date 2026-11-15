import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/utils.dart';

/// Representa el registro de asistencia de un estudiante a una clase.
///
/// Diseñado para persistir en Firestore bajo la colección `attendances`
/// o como subcolección dentro de `courses/{courseId}/sessions/{sessionId}/attendances`.
class AttendanceModel {
  AttendanceModel({
    this.id = '',
    required this.courseId,
    required this.sessionId,
    required this.studentEmail,
    this.studentId = '',
    this.studentName = '',
    required this.date,
    this.status = 'Presente',
    this.method = 'double',
    this.detail = '',
  });

  final String id;
  final String courseId;
  final String sessionId;
  final String studentId;
  final String studentEmail;
  final String studentName;
  final DateTime date;

  /// Estado: 'Presente' | 'Tarde' | 'Ausente' | 'Justificado'
  final String status;

  /// Método utilizado: 'ble' | 'challenge' | 'double' | 'manual'
  final String method;

  /// Detalle opcional o descripción del registro
  final String detail;

  /// Fecha formateada para la interfaz (ej. "14 nov, 08:30 a. m.")
  String get dateFormatted => '${shortDate(date)}, ${timeLabel(date)}';

  /// Descripción legible del método o justificación
  String get displayDetail {
    if (detail.isNotEmpty) return detail;
    switch (method) {
      case 'ble':
        return 'Validado por Proximidad (BLE)';
      case 'challenge':
        return 'Validado por Reto visual';
      case 'double':
        return 'Validado por Doble factor';
      default:
        return 'Registro manual docente';
    }
  }

  factory AttendanceModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return AttendanceModel(
      id: d.id,
      courseId: (m['courseId'] ?? '') as String,
      sessionId: (m['sessionId'] ?? '') as String,
      studentId: (m['studentId'] ?? '') as String,
      studentEmail: (m['studentEmail'] ?? '') as String,
      studentName: (m['studentName'] ?? '') as String,
      date: (m['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: (m['status'] ?? 'Presente') as String,
      method: (m['method'] ?? 'double') as String,
      detail: (m['detail'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'courseId': courseId,
    'sessionId': sessionId,
    'studentId': studentId,
    'studentEmail': studentEmail.toLowerCase(),
    'studentName': studentName,
    'date': Timestamp.fromDate(date),
    'status': status,
    'method': method,
    'detail': detail,
  };
}
