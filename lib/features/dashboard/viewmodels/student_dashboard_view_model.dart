import 'package:flutter/foundation.dart';

import '../models/dashboard_announcement.dart';

enum StudentDashboardTab { home, history, sos, profile }

class StudentDashboardViewModel extends ChangeNotifier {
  StudentDashboardTab _selectedTab = StudentDashboardTab.home;
  DashboardAnnouncement? _announcement;

  StudentDashboardTab get selectedTab => _selectedTab;
  DashboardAnnouncement? get announcement => _announcement;

  void selectTab(StudentDashboardTab tab) {
    if (_selectedTab == tab) return;
    _selectedTab = tab;
    notifyListeners();
  }

  void openHistory() => selectTab(StudentDashboardTab.history);

  void openSos() => selectTab(StudentDashboardTab.sos);

  void openProfile() => selectTab(StudentDashboardTab.profile);

  void setAnnouncement(DashboardAnnouncement? announcement) {
    _announcement = announcement;
    notifyListeners();
  }
}
