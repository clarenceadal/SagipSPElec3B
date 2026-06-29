import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/validators.dart';
import '../models/student_profile.dart';
import '../viewmodels/student_profile_view_model.dart';

class StudentProfileView extends StatefulWidget {
  const StudentProfileView({required this.viewModel, super.key});

  final StudentProfileViewModel viewModel;

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadProfile();
  }

  @override
  void dispose() {
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final viewModel = widget.viewModel;
        final profile = viewModel.profile;

        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (profile == null) {
          return _ProfileMessage(
            icon: Icons.person_off_outlined,
            title: 'Profile unavailable',
            message: viewModel.errorMessage ?? 'Unable to load your profile.',
            action: TextButton.icon(
              onPressed: viewModel.loadProfile,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          );
        }

        if (viewModel.isEditing) {
          _syncControllers(profile);
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            const _ProfileAvatar(),
            const SizedBox(height: 18),
            if (viewModel.errorMessage != null)
              _MessageCard(
                message: viewModel.errorMessage!,
                color: const Color(0xFFFFE4E4),
              ),
            if (viewModel.successMessage != null)
              _MessageCard(
                message: viewModel.successMessage!,
                color: const Color(0xFFE7F8EC),
              ),
            if (viewModel.isEditing)
              _EditProfileForm(
                formKey: _formKey,
                profile: profile,
                contactController: _contactController,
                emailController: _emailController,
                isSaving: viewModel.isSaving,
                onCancel: viewModel.cancelEditing,
                onSave: _save,
              )
            else
              _ProfileDetails(
                profile: profile,
                onEdit: viewModel.startEditing,
              ),
          ],
        );
      },
    );
  }

  void _syncControllers(StudentProfile profile) {
    if (_contactController.text != profile.contactNumber) {
      _contactController.text = profile.contactNumber;
    }
    if (_emailController.text != profile.email) {
      _emailController.text = profile.email;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.viewModel.saveChanges(
      contactNumber: _contactController.text,
      email: _emailController.text,
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFFE8ECE8),
            child: Icon(
              Icons.person_rounded,
              size: 62,
              color: Colors.grey.shade500,
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFFF2B705),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({required this.profile, required this.onEdit});

  final StudentProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileTile(
          icon: Icons.badge_outlined,
          label: 'Student ID',
          value: profile.studentId,
        ),
        _ProfileTile(
          icon: Icons.person_outline,
          label: 'Full Name',
          value: profile.fullName,
        ),
        _ProfileTile(
          icon: Icons.cake_outlined,
          label: 'Birthday',
          value: _formatDate(profile.birthDate),
        ),
        _ProfileTile(
          icon: Icons.account_balance_outlined,
          label: 'Department',
          value: profile.department,
        ),
        _ProfileTile(
          icon: Icons.school_outlined,
          label: 'Course',
          value: profile.course,
        ),
        _ProfileTile(
          icon: Icons.calendar_today_outlined,
          label: 'Year Level',
          value: profile.yearLevel == null ? '' : 'Year ${profile.yearLevel}',
        ),
        _ProfileTile(
          icon: Icons.phone_outlined,
          label: 'Contact Number',
          value: profile.contactNumber,
        ),
        _ProfileTile(
          icon: Icons.email_outlined,
          label: 'Email',
          value: profile.email,
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('EDIT PROFILE'),
          ),
        ),
      ],
    );
  }
}

class _EditProfileForm extends StatelessWidget {
  const _EditProfileForm({
    required this.formKey,
    required this.profile,
    required this.contactController,
    required this.emailController,
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final StudentProfile profile;
  final TextEditingController contactController;
  final TextEditingController emailController;
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReadOnlyField(
            label: 'Student ID',
            icon: Icons.badge_outlined,
            value: profile.studentId,
          ),
          _ReadOnlyField(
            label: 'Full Name',
            icon: Icons.person_outline,
            value: profile.fullName,
          ),
          _ReadOnlyField(
            label: 'Birthday',
            icon: Icons.cake_outlined,
            value: _formatDate(profile.birthDate),
          ),
          _ReadOnlyField(
            label: 'Department',
            icon: Icons.account_balance_outlined,
            value: profile.department,
          ),
          _ReadOnlyField(
            label: 'Course',
            icon: Icons.school_outlined,
            value: profile.course,
          ),
          _ReadOnlyField(
            label: 'Year Level',
            icon: Icons.calendar_today_outlined,
            value: profile.yearLevel == null ? '' : 'Year ${profile.yearLevel}',
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: contactController,
            enabled: !isSaving,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Contact Number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (value) => Validators.required(value, 'Contact number'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: emailController,
            enabled: !isSaving,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: Validators.studentEmail,
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: isSaving ? null : onSave,
            child: isSaving
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('SAVE CHANGES'),
          ),
          TextButton(
            onPressed: isSaving ? null : onCancel,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E4E0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 21, color: const Color(0xFF2F3330)),
          const SizedBox(width: 12),
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not set' : value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.icon,
    required this.value,
  });

  final String label;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(message),
      ),
    );
  }
}

class _ProfileMessage extends StatelessWidget {
  const _ProfileMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: const Color(0xFF9AA09B)),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            action,
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) return '';
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$month/$day/${value.year}';
}
