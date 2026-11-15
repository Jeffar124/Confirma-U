import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirma_u/models/attendance_model.dart';
import 'package:confirma_u/models/course_model.dart';
import 'package:confirma_u/models/session_model.dart';
import 'package:confirma_u/models/student_model.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _courses =>
      _db.collection('courses');
  CollectionReference<Map<String, dynamic>> get _attendances =>
      _db.collection('attendances');

  // ------------------------------------------------------------------ cursos
  Stream<List<CourseModel>> teacherCourses(String uid) => _courses
      .where('teacherId', isEqualTo: uid)
      .snapshots()
      .map((s) => _sorted(s.docs.map(CourseModel.fromDoc).toList()));

  Stream<List<CourseModel>> studentCourses(String email) => _courses
      .where('studentEmails', arrayContains: email.toLowerCase())
      .snapshots()
      .map((s) => _sorted(s.docs.map(CourseModel.fromDoc).toList()));

  Stream<CourseModel?> courseStream(String id) => _courses
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? CourseModel.fromDoc(d) : null);

  List<CourseModel> _sorted(List<CourseModel> l) {
    l.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return l;
  }

  Future<String> createCourse(
    CourseModel c,
    List<StudentModel> students,
  ) async {
    final ref = _courses.doc();
    final batch = _db.batch();
    batch.set(ref, {
      ...c.toMap(),
      'studentEmails': students.map((s) => s.email.toLowerCase()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    for (final s in students) {
      batch.set(ref.collection('students').doc(), s.toMap());
    }
    await batch.commit();
    return ref.id;
  }

  // ------------------------------------------------------------- estudiantes
  Stream<List<StudentModel>> students(String courseId) =>
      _courses.doc(courseId).collection('students').snapshots().map((s) {
        final l = s.docs.map(StudentModel.fromDoc).toList();
        l.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return l;
      });

  /// Crea o actualiza un estudiante y mantiene `studentEmails` del curso.
  Future<void> saveStudent(
    String courseId,
    StudentModel s, {
    String? previousEmail,
  }) async {
    final cref = _courses.doc(courseId);
    final sref = s.id.isEmpty
        ? cref.collection('students').doc()
        : cref.collection('students').doc(s.id);
    final batch = _db.batch();
    batch.set(sref, s.toMap());
    if (previousEmail != null &&
        previousEmail.toLowerCase() != s.email.toLowerCase()) {
      batch.update(cref, {
        'studentEmails': FieldValue.arrayRemove([previousEmail.toLowerCase()]),
      });
    }
    batch.update(cref, {
      'studentEmails': FieldValue.arrayUnion([s.email.toLowerCase()]),
    });
    await batch.commit();
  }

  Future<void> deleteStudent(String courseId, StudentModel s) async {
    final cref = _courses.doc(courseId);
    final batch = _db.batch();
    batch.delete(cref.collection('students').doc(s.id));
    batch.update(cref, {
      'studentEmails': FieldValue.arrayRemove([s.email.toLowerCase()]),
    });
    await batch.commit();
  }

  // --------------------------------------------------- sesiones y asistencias
  /// Inicia una nueva sesión de clase (docente).
  Future<String> createSession(SessionModel session) async {
    final ref = _courses.doc(session.courseId).collection('sessions').doc();
    await ref.set({
      ...session.toMap(),
      'id': ref.id,
    });
    return ref.id;
  }

  /// Cierra una sesión de clase activa.
  Future<void> closeSession(String courseId, String sessionId) async {
    await _courses.doc(courseId).collection('sessions').doc(sessionId).update({
      'status': 'closed',
      'closedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Escucha la sesión activa de un curso en tiempo real.
  Stream<SessionModel?> activeSessionStream(String courseId) {
    return _courses
        .doc(courseId)
        .collection('sessions')
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty ? null : SessionModel.fromDoc(s.docs.first));
  }

  /// Registra la asistencia confirmada de un estudiante.
  Future<void> recordAttendance(AttendanceModel a) async {
    final ref = _attendances.doc();
    final batch = _db.batch();

    // Guarda en la colección global para consultas rápidas de historial
    batch.set(ref, a.toMap());

    // Incrementa el contador de presentes en la sesión del curso si existe sessionId
    if (a.sessionId.isNotEmpty) {
      final sessionRef = _courses
          .doc(a.courseId)
          .collection('sessions')
          .doc(a.sessionId);
      batch.update(sessionRef, {
        'presentCount': FieldValue.increment(1),
      });
    }

    await batch.commit();
  }

  /// Stream del historial de asistencias de un estudiante en un curso específico.
  Stream<List<AttendanceModel>> studentAttendance(
    String courseId,
    String studentEmail,
  ) {
    return _attendances
        .where('courseId', isEqualTo: courseId)
        .where('studentEmail', isEqualTo: studentEmail.toLowerCase())
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map(AttendanceModel.fromDoc).toList());
  }
}
