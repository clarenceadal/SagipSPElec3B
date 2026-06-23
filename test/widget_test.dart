import 'package:flutter_test/flutter_test.dart';
import 'package:sagip/app/app.dart';
import 'package:sagip/features/auth/models/app_user.dart';
import 'package:sagip/features/auth/models/student_registration.dart';
import 'package:sagip/features/auth/services/auth_service.dart';
import 'package:sagip/features/sos/models/emergency_type.dart';
import 'package:sagip/features/sos/models/incident_submission.dart';
import 'package:sagip/features/sos/services/incident_service.dart';

void main() {
  testWidgets('shows the sign-in screen when there is no session', (
    tester,
  ) async {
    await tester.pumpWidget(
      SagipApp(
        authService: _FakeAuthService(),
        incidentService: _FakeIncidentService(),
      ),
    );
    await tester.pump();

    expect(find.text('Student Login'), findsOneWidget);
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
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome,'), findsOneWidget);
    expect(find.text('Adal, Clarence A.'), findsOneWidget);
    expect(find.text('Announcements'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Incident History'), findsOneWidget);

    await tester.tap(find.text('SOS'));
    await tester.pumpAndSettle();

    expect(find.text('Send an Emergency Alert'), findsOneWidget);
    expect(find.text('Select Emergency Type'), findsOneWidget);
    expect(find.text('SEND SOS'), findsOneWidget);
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

class _FakeIncidentService implements IncidentService {
  @override
  Future<List<EmergencyType>> getEmergencyTypes() async {
    return const [
      EmergencyType(id: 'medical-id', name: 'Medical Emergency'),
    ];
  }

  @override
  Future<void> submitIncident(IncidentSubmission submission) async {}
}
