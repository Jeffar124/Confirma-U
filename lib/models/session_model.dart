import 'package:cloud_firestore/cloud_firestore.dart';

/// Estado de una sesión de clase.
enum SessionStatus { active, closed }

/// Modelo para una sesión de clase en vivo creada por el docente.
///
/// Diseñado para persistir en Firestore bajo: `courses/{courseId}/sessions/{sessionId}`.
class SessionModel {
  SessionModel({
    this.id = '',
    required this.courseId,
    required this.teacherId,
    required this.createdAt,
    this.status = SessionStatus.active,
    this.method = 'double',
    this.challengeEmoji = '🚀',
    this.bleToken = '',
    this.minutes = 10,
    this.presentCount = 0,
    this.closedAt,
  });

  final String id;
  final String courseId;
  final String teacherId;
  final DateTime createdAt;
  final SessionStatus status;

  /// Método de verificación: 'ble' | 'challenge' | 'double'
  final String method;

  /// Emoji asignado al reto si el método lo requiere
  final String challengeEmoji;

  /// Identificador/token emitido por BLE si se usa proximidad
  final String bleToken;

  /// Duración en minutos de la ventana de asistencia
  final int minutes;

  /// Cantidad de estudiantes que han registrado asistencia
  final int presentCount;

  /// Fecha/hora de cierre de la sesión
  final DateTime? closedAt;

  bool get isActive => status == SessionStatus.active;

  factory SessionModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return SessionModel(
      id: d.id,
      courseId: (m['courseId'] ?? '') as String,
      teacherId: (m['teacherId'] ?? '') as String,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: (m['status'] == 'closed')
          ? SessionStatus.closed
          : SessionStatus.active,
      method: (m['method'] ?? 'double') as String,
      challengeEmoji: (m['challengeEmoji'] ?? '🚀') as String,
      bleToken: (m['bleToken'] ?? '') as String,
      minutes: (m['minutes'] ?? 10) as int,
      presentCount: (m['presentCount'] ?? 0) as int,
      closedAt: (m['closedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'courseId': courseId,
    'teacherId': teacherId,
    'createdAt': Timestamp.fromDate(createdAt),
    'status': status == SessionStatus.closed ? 'closed' : 'active',
    'method': method,
    'challengeEmoji': challengeEmoji,
    'bleToken': bleToken,
    'minutes': minutes,
    'presentCount': presentCount,
    'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
  };
}
