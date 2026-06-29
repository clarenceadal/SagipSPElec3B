import 'package:flutter/foundation.dart';

import '../models/student_profile.dart';
import '../services/student_profile_service.dart';

class StudentProfileViewModel extends ChangeNotifier {
  StudentProfileViewModel({
    required StudentProfileService profileService,
    required String profileId,
  }) : _profileService = profileService,
       _profileId = profileId;

  final StudentProfileService _profileService;
  final String _profileId;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isEditing = false;
  String? _errorMessage;
  String? _successMessage;
  StudentProfile? _profile;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isEditing => _isEditing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  StudentProfile? get profile => _profile;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _profile = await _profileService.getStudentProfile(_profileId);
    } catch (error) {
      _errorMessage = 'Unable to load student profile: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startEditing() {
    _isEditing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void cancelEditing() {
    _isEditing = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> saveChanges({
    required String contactNumber,
    required String email,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _profileService.updateStudentProfile(
        profileId: _profileId,
        contactNumber: contactNumber,
        email: email,
      );

      _profile = _profile?.copyWith(
        contactNumber: contactNumber.trim(),
        email: email.trim(),
      );
      _isEditing = false;
      _successMessage = 'Profile updated successfully.';
      return true;
    } catch (error) {
      _errorMessage = 'Unable to update profile: $error';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
