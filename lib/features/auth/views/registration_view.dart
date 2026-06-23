import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/validators.dart';
import '../models/academic_program.dart';
import '../models/student_registration.dart';
import '../services/auth_service.dart';
import '../viewmodels/registration_view_model.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_scaffold.dart';

class RegistrationView extends StatefulWidget {
  const RegistrationView({required this.authService, super.key});

  final AuthService authService;

  @override
  State<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleInitialController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  late final RegistrationViewModel _viewModel;
  int _yearLevel = 1;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _viewModel = RegistrationViewModel(widget.authService);
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleInitialController.dispose();
    _birthDateController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) return;
    if (_viewModel.selectedDepartment == null ||
        _viewModel.selectedCourse == null) {
      return;
    }

    final success = await _viewModel.register(
      StudentRegistration(
        studentId: _studentIdController.text,
        lastName: _lastNameController.text,
        firstName: _firstNameController.text,
        middleInitial: _middleInitialController.text,
        birthDate: _birthDate!,
        department: _viewModel.selectedDepartment!.name,
        course: _viewModel.selectedCourse!,
        yearLevel: _yearLevel,
        contactNumber: _contactController.text,
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );

    if (!mounted || !success) return;

    if (_viewModel.requiresEmailConfirmation) {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm your email'),
            content: const Text(
              'Your account was created. Open the confirmation link sent to '
              'your email, then return and sign in.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _selectBirthDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'Select birthday',
    );

    if (selected == null) return;
    setState(() {
      _birthDate = selected;
      _birthDateController.text =
          '${selected.month.toString().padLeft(2, '0')}/'
          '${selected.day.toString().padLeft(2, '0')}/'
          '${selected.year}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Student registration',
      subtitle: 'Enter your USJ-R student information.',
      showBackButton: true,
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthErrorBanner(message: _viewModel.errorMessage),
                _field(
                  controller: _studentIdController,
                  label: 'Student ID',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(20),
                  ],
                ),
                _field(
                  controller: _lastNameController,
                  label: 'Last name',
                  icon: Icons.person_outline,
                  autofillHints: const [AutofillHints.familyName],
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [_nameFormatter],
                ),
                _field(
                  controller: _firstNameController,
                  label: 'First name',
                  icon: Icons.person_outline,
                  autofillHints: const [AutofillHints.givenName],
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [_nameFormatter],
                ),
                _field(
                  controller: _middleInitialController,
                  label: 'Middle initial (optional)',
                  icon: Icons.person_outline,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                    LengthLimitingTextInputFormatter(1),
                  ],
                  validator: (_) => null,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _birthDateController,
                    readOnly: true,
                    enabled: !_viewModel.isLoading,
                    onTap: _selectBirthDate,
                    decoration: const InputDecoration(
                      labelText: 'Birthday',
                      hintText: 'Select your birthday',
                      prefixIcon: Icon(Icons.cake_outlined),
                      suffixIcon: Icon(Icons.calendar_month_outlined),
                    ),
                    validator: (_) =>
                        _birthDate == null ? 'Birthday is required.' : null,
                  ),
                ),
                _departmentDropdown(),
                _courseDropdown(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<int>(
                    initialValue: _yearLevel,
                    decoration: const InputDecoration(
                      labelText: 'Year level',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    items: List.generate(
                      6,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('Year ${index + 1}'),
                      ),
                    ),
                    onChanged: _viewModel.isLoading
                        ? null
                        : (value) => setState(() => _yearLevel = value ?? 1),
                  ),
                ),
                _field(
                  controller: _contactController,
                  label: 'Contact number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                ),
                _field(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.studentEmail,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _passwordController,
                    enabled: !_viewModel.isLoading,
                    obscureText: _viewModel.obscurePassword,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: _viewModel.togglePasswordVisibility,
                        icon: Icon(
                          _viewModel.obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: Validators.password,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    controller: _confirmationController,
                    enabled: !_viewModel.isLoading,
                    obscureText: _viewModel.obscureConfirmation,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: _viewModel.toggleConfirmationVisibility,
                        icon: Icon(
                          _viewModel.obscureConfirmation
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                ),
                FilledButton(
                  onPressed: _viewModel.isLoading ? null : _submit,
                  child: _viewModel.isLoading
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('CREATE ACCOUNT'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _viewModel.isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Back to sign in'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _departmentDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<AcademicDepartment>(
        initialValue: _viewModel.selectedDepartment,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Department',
          prefixIcon: Icon(Icons.account_balance_outlined),
        ),
        hint: const Text('Select department'),
        items: _viewModel.departments
            .map(
              (department) => DropdownMenuItem(
                value: department,
                child: Text(
                  department.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: _viewModel.isLoading
            ? null
            : _viewModel.selectDepartment,
        validator: (value) =>
            value == null ? 'Department is required.' : null,
      ),
    );
  }

  Widget _courseDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        key: ValueKey(_viewModel.selectedDepartment?.name),
        initialValue: _viewModel.selectedCourse,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Course',
          prefixIcon: Icon(Icons.school_outlined),
        ),
        hint: Text(
          _viewModel.selectedDepartment == null
              ? 'Select department first'
              : 'Select course',
        ),
        items: _viewModel.availableCourses
            .map(
              (course) => DropdownMenuItem(
                value: course,
                child: Text(course, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged:
            _viewModel.isLoading || _viewModel.selectedDepartment == null
            ? null
            : _viewModel.selectCourse,
        validator: (value) => value == null ? 'Course is required.' : null,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: !_viewModel.isLoading,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: validator ?? (value) => Validators.required(value, label),
      ),
    );
  }

  static final TextInputFormatter _nameFormatter =
      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z .'-]"));
}
