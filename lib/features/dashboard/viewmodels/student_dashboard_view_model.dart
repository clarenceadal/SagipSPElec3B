import 'package:flutter/foundation.dart';

import '../../broadcast/services/broadcast_service.dart';
import '../models/dashboard_announcement.dart';

enum StudentDashboardTab { home, history, sos, profile }

class StudentDashboardViewModel extends ChangeNotifier {
  StudentDashboardViewModel(this._broadcastService);

  final BroadcastService _broadcastService;

  StudentDashboardTab _selectedTab = StudentDashboardTab.home;
  DashboardAnnouncement? _announcement;
  String? _announcementError;
  bool _isLoadingAnnouncement = false;

  StudentDashboardTab get selectedTab => _selectedTab;
  DashboardAnnouncement? get announcement => _announcement;
  String? get announcementError => _announcementError;
  bool get isLoadingAnnouncement => _isLoadingAnnouncement;

  void selectTab(StudentDashboardTab tab) {
    if (_selectedTab == tab) return;
    _selectedTab = tab;
    notifyListeners();
  }

  void openHistory() => selectTab(StudentDashboardTab.history);

  void openSos() => selectTab(StudentDashboardTab.sos);

  void openProfile() => selectTab(StudentDashboardTab.profile);

  Future<void> loadLatestAnnouncement() async {
    _isLoadingAnnouncement = true;
    _announcementError = null;
    notifyListeners();

    try {
      final broadcast = await _broadcastService.getLatestBroadcast();
      _announcement = broadcast == null
          ? null
          : DashboardAnnouncement(
              title: broadcast.title,
              message: broadcast.message,
            );
    } catch (error) {
      _announcementError = 'Unable to load announcements: $error';
    } finally {
      _isLoadingAnnouncement = false;
      notifyListeners();
    }
  }

  void setAnnouncementForTest(DashboardAnnouncement? announcement) {
    _announcement = announcement;
    notifyListeners();
  }
}
