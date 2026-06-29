import 'package:flutter/foundation.dart';

import '../../sos/services/incident_service.dart';
import '../models/admin_incident.dart';

class SsdDashboardViewModel extends ChangeNotifier {
  SsdDashboardViewModel(this._incidentService);

  final IncidentService _incidentService;

  bool _isLoading = false;
  String? _errorMessage;
  List<AdminIncident> _incidents = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AdminIncident> get incidents => _incidents;

  int get totalIncidents => _incidents.length;
  int get activeIncidents => _countByStatusExcept('resolved');
  int get respondingIncidents => _countByStatus('responding');
  int get resolvedIncidents => _countByStatus('resolved');

  Future<void> loadIncidents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _incidents = await _incidentService.getAdminIncidents();
    } catch (error) {
      _errorMessage = 'Unable to load emergency reports: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateIncidentStatus(String incidentId, String status) async {
    final oldIncidents = _incidents;
    _incidents = [
      for (final incident in _incidents)
        if (incident.id == incidentId)
          AdminIncident(
            id: incident.id,
            emergencyType: incident.emergencyType,
            status: status,
            createdAt: incident.createdAt,
            studentName: incident.studentName,
            studentId: incident.studentId,
            location: incident.location,
            course: incident.course,
            yearLevel: incident.yearLevel,
            description: incident.description,
          )
        else
          incident,
    ];
    notifyListeners();

    try {
      await _incidentService.updateIncidentStatus(incidentId, status);
    } catch (error) {
      _incidents = oldIncidents;
      _errorMessage = 'Unable to update incident status: $error';
      notifyListeners();
    }
  }

  int _countByStatus(String status) {
    return _incidents
        .where((incident) => incident.status.toLowerCase() == status)
        .length;
  }

  int _countByStatusExcept(String status) {
    return _incidents
        .where((incident) => incident.status.toLowerCase() != status)
        .length;
  }
}
