import 'package:flutter_test/flutter_test.dart';
import 'package:sagip/app/app.dart';
import 'package:sagip/features/auth/models/app_user.dart';
import 'package:sagip/features/auth/models/student_registration.dart';
import 'package:sagip/features/auth/services/auth_service.dart';
import 'package:sagip/features/admin/models/admin_incident.dart';
import 'package:sagip/features/broadcast/models/broadcast_message.dart';
import 'package:sagip/features/broadcast/services/broadcast_service.dart';
import 'package:sagip/features/sos/models/emergency_type.dart';
import 'package:sagip/features/sos/models/incident_submission.dart';
import 'package:sagip/features/sos/services/incident_service.dart';
import 'package:sagip/features/profile/models/student_profile.dart';
import 'package:sagip/features/profile/services/student_profile_service.dart';
import 'package:sagip/features/history/models/student_incident.dart';

void main() {
  testWidgets('shows the sign-in screen when there is no session', (
    tester,
  ) async {
    await tester.pumpWidget(
      SagipApp(
        authService: _FakeAuthService(),
        incidentService: _FakeIncidentService(),
        studentProfileService: _FakeStudentProfileService(),
        broadcastService: _FakeBroadcastService(),
      ),
    );
    await tester.pump();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Register here'), findsOneWidget);
  });

  testWidgets('shows the student dashboard for a student session', (
    tester,
  ) async {
    const student = AppUser(
      id: 'student-id',
      email: 'student@usjr.edu.ph',
      fullName: 'Adal, Clarence A.',
      role: UserRole.student,
    );

    await tester.pumpWidget(
      SagipApp(
        authService: _FakeAuthService(user: student),
        incidentService: _FakeIncidentService(),
        studentProfileService: _FakeStudentProfileService(),
        broadcastService: _FakeBroadcastService(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome,'), findsOneWidget);
    expect(find.text('Adal, Clarence A.'), findsOneWidget);
    expect(find.text('No announcements yet'), findsOneWidget);
    expect(
      find.text('Campus-wide announcements from SSD will appear here.'),
      findsOneWidget,
    );

    await tester.tap(find.text('SOS'));
    await tester.pumpAndSettle();

    expect(find.text('Send an Emergency Alert'), findsOneWidget);
    expect(find.text('Select Emergency Type'), findsOneWidget);
    expect(find.text('SEND SOS'), findsOneWidget);
  });

  testWidgets('shows the SSD dashboard for an admin session', (tester) async {
    const admin = AppUser(
      id: 'admin-id',
      email: 'ssd.admin@usjr.edu.ph',
      fullName: 'SSD Administrator',
      role: UserRole.admin,
    );

    await tester.pumpWidget(
      SagipApp(
        authService: _FakeAuthService(user: admin),
        incidentService: _FakeIncidentService(),
        studentProfileService: _FakeStudentProfileService(),
        broadcastService: _FakeBroadcastService(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SSD Dashboard'), findsOneWidget);
    expect(find.text('Emergency Reports'), findsOneWidget);
    expect(find.text('Medical Emergency'), findsOneWidget);
    expect(find.text('Adal, Clarence A.'), findsOneWidget);
  });
}

class _FakeAuthService implements AuthService {
  _FakeAuthService({this.user});

  final AppUser? user;

  @override
  Stream<AuthSessionEvent> get authEvents => const Stream.empty();

  @override
  bool get hasSession => user != null;

  @override
  Future<AppUser?> getCurrentUser() async => user;

  @override
  Future<bool> registerStudent(StudentRegistration registration) async => true;

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> updatePassword(String password) async {}
}

class _FakeBroadcastService implements BroadcastService {
  @override
  Future<void> createBroadcast({
    required String title,
    required String message,
  }) async {}

  @override
  Future<BroadcastMessage?> getLatestBroadcast() async => null;

  @override
  Future<List<BroadcastMessage>> getRecentBroadcasts() async => const [];
}

class _FakeStudentProfileService implements StudentProfileService {
  @override
  Future<StudentProfile> getStudentProfile(String profileId) async {
    return StudentProfile(
      studentId: '2026-0001',
      fullName: 'Adal, Clarence A.',
      birthDate: DateTime(2003, 12, 30),
      department: 'School of Computer Studies',
      course: 'Bachelor of Science in Information Technology',
      yearLevel: 3,
      contactNumber: '09664152740',
      email: 'student@usjr.edu.ph',
    );
  }

  @override
  Future<void> updateStudentProfile({
    required String profileId,
    required String contactNumber,
    required String email,
  }) async {}
}

class _FakeIncidentService implements IncidentService {
  @override
  Future<List<AdminIncident>> getAdminIncidents() async {
    return [
      AdminIncident(
        id: 'incident-id',
        emergencyType: 'Medical Emergency',
        status: 'pending',
        createdAt: DateTime(2026, 6, 28, 10, 25),
        studentName: 'Adal, Clarence A.',
        studentId: '2026-0001',
        location: 'USJ-R Basak Campus',
      ),
    ];
  }

  @override
  Future<List<EmergencyType>> getEmergencyTypes() async {
    return const [
      EmergencyType(id: 'medical-id', name: 'Medical Emergency'),
    ];
  }

  @override
  Future<void> submitIncident(IncidentSubmission submission) async {}

  @override
  Future<void> updateIncidentStatus(String incidentId, String status) async {}

  @override
  Future<List<StudentIncident>> getStudentIncidents(String profileId) async {
    return [
      StudentIncident(
        id: 'student-incident-id',
        emergencyType: 'Medical Emergency',
        status: 'pending',
        createdAt: DateTime(2026, 6, 28, 10, 25),
      ),
    ];
  }
}
