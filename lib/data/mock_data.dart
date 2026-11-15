import '../models/attendance_model.dart';

// ─── Constantes para el Reto de Asistencia ───────────────────────────────────

/// Emoji correcto para la demostración del reto en el aula
const String kDemoChallengeEmoji = '🚀';

/// Opciones de emojis mostradas en la cuadrícula 3x3 del reto
const List<String> kChallengeEmojis = [
  '🚀',
  '⚡',
  '🎯',
  '🔥',
  '🌟',
  '💡',
  '🎓',
  '📚',
  '🧩',
];

// ─── Métricas Simuladas para Historial ────────────────────────────────────────

const int mockAttendancePercent = 85;
const int mockAttendedClasses = 17;
const int mockTotalClasses = 20;

// ─── Registros de Historial de Asistencia ─────────────────────────────────────

final List<AttendanceModel> mockHistory = [
  AttendanceModel(
    id: 'mock-1',
    courseId: 'demo-course',
    sessionId: 'session-1',
    studentEmail: 'estudiante@udla.edu.co',
    date: DateTime.now().subtract(const Duration(hours: 2)),
    status: 'Presente',
    method: 'double',
    detail: 'Validado por Doble factor · Salón 201',
  ),
  AttendanceModel(
    id: 'mock-2',
    courseId: 'demo-course',
    sessionId: 'session-2',
    studentEmail: 'estudiante@udla.edu.co',
    date: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
    status: 'Presente',
    method: 'challenge',
    detail: 'Validado por Reto visual · Salón 201',
  ),
  AttendanceModel(
    id: 'mock-3',
    courseId: 'demo-course',
    sessionId: 'session-3',
    studentEmail: 'estudiante@udla.edu.co',
    date: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
    status: 'Tarde',
    method: 'ble',
    detail: 'Ingreso 15 min después · BLE',
  ),
  AttendanceModel(
    id: 'mock-4',
    courseId: 'demo-course',
    sessionId: 'session-4',
    studentEmail: 'estudiante@udla.edu.co',
    date: DateTime.now().subtract(const Duration(days: 7, hours: 3)),
    status: 'Ausente',
    method: 'manual',
    detail: 'Sin registro en el aula',
  ),
  AttendanceModel(
    id: 'mock-5',
    courseId: 'demo-course',
    sessionId: 'session-5',
    studentEmail: 'estudiante@udla.edu.co',
    date: DateTime.now().subtract(const Duration(days: 9, hours: 5)),
    status: 'Justificado',
    method: 'manual',
    detail: 'Incapacidad médica validada',
  ),
  AttendanceModel(
    id: 'mock-6',
    courseId: 'demo-course',
    sessionId: 'session-6',
    studentEmail: 'estudiante@udla.edu.co',
    date: DateTime.now().subtract(const Duration(days: 12, hours: 1)),
    status: 'Presente',
    method: 'double',
    detail: 'Validado por Doble factor · Salón 201',
  ),
];
