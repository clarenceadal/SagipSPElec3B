import 'package:flutter/foundation.dart';

import '../models/emergency_type.dart';
import '../models/incident_submission.dart';
import '../services/incident_service.dart';

class SosViewModel extends ChangeNotifier {
  SosViewModel({
    required IncidentService incidentService,
    required String profileId,
  }) : _incidentService = incidentService,
       _profileId = profileId;

  final IncidentService _incidentService;
  final String _profileId;

  List<EmergencyType> _emergencyTypes = const [];
  EmergencyType? _selectedType;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<EmergencyType> get emergencyTypes => _emergencyTypes;
  EmergencyType? get selectedType => _selectedType;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<void> loadEmergencyTypes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _emergencyTypes = await _incidentService.getEmergencyTypes();
    } catch (_) {
      _errorMessage = 'Emergency types could not be loaded. Try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectEmergencyType(EmergencyType? type) {
    _selectedType = type;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> submit(String details) async {
    final type = _selectedType;
    if (type == null) {
      _errorMessage = 'Select an emergency type.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _incidentService.submitIncident(
        IncidentSubmission(
          profileId: _profileId,
          emergencyTypeId: type.id,
          details: details,
          capturedAt: DateTime.now(),
        ),
      );
      _selectedType = null;
      return true;
    } catch (_) {
      _errorMessage = 'The incident could not be submitted. Try again.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
