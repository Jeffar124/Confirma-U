import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirma_u/models/course_model.dart';
import 'package:confirma_u/models/student_model.dart';

/// Estructura en Firestore:
///   users/{uid}                       -> perfil (name, email, code, role)
///   courses/{courseId}                -> curso (teacherId, studentEmails[], ...)
///   courses/{courseId}/students/{id}  -> estudiantes inscritos
class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _courses =>
      _db.collection('courses');

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
}
