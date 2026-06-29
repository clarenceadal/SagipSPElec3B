import 'package:flutter/foundation.dart';

import '../../sos/services/incident_service.dart';
import '../models/student_incident.dart';

class IncidentHistoryViewModel extends ChangeNotifier {
  IncidentHistoryViewModel({
    required IncidentService incidentService,
    required String profileId,
  }) : _incidentService = incidentService,
       _profileId = profileId;

  final IncidentService _incidentService;
  final String _profileId;

  bool _isLoading = false;
  String? _errorMessage;
  List<StudentIncident> _incidents = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<StudentIncident> get incidents => _incidents;

  Future<void> loadIncidents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _incidents = await _incidentService.getStudentIncidents(_profileId);
    } catch (error) {
      _errorMessage = 'Unable to load incident history: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
