import '../models/academic_program.dart';
import '../models/student_registration.dart';
import '../services/auth_service.dart';
import 'auth_form_view_model.dart';

class RegistrationViewModel extends AuthFormViewModel {
  RegistrationViewModel(this._authService);

  final AuthService _authService;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _requiresEmailConfirmation = false;
  AcademicDepartment? _selectedDepartment;
  String? _selectedCourse;

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmation => _obscureConfirmation;
  bool get requiresEmailConfirmation => _requiresEmailConfirmation;
  List<AcademicDepartment> get departments =>
      AcademicProgramCatalog.departments;
  AcademicDepartment? get selectedDepartment => _selectedDepartment;
  String? get selectedCourse => _selectedCourse;
  List<String> get availableCourses => _selectedDepartment?.courses ?? const [];

  void selectDepartment(AcademicDepartment? department) {
    if (_selectedDepartment == department) return;
    _selectedDepartment = department;
    _selectedCourse = null;
    notifyListeners();
  }

  void selectCourse(String? course) {
    if (_selectedCourse == course) return;
    _selectedCourse = course;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmationVisibility() {
    _obscureConfirmation = !_obscureConfirmation;
    notifyListeners();
  }

  Future<bool> register(StudentRegistration registration) {
    return run(() async {
      _requiresEmailConfirmation = await _authService.registerStudent(
        registration,
      );
    });
  }
}
