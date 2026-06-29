import 'package:flutter/material.dart';

import '../../auth/models/app_user.dart';
import '../../broadcast/services/broadcast_service.dart';
import '../../history/viewmodels/incident_history_view_model.dart';
import '../../history/views/incident_history_view.dart';
import '../../profile/services/student_profile_service.dart';
import '../../profile/viewmodels/student_profile_view_model.dart';
import '../../profile/views/student_profile_view.dart';
import '../../sos/services/incident_service.dart';
import '../../sos/viewmodels/sos_view_model.dart';
import '../../sos/views/sos_view.dart';
import '../models/dashboard_announcement.dart';
import '../viewmodels/student_dashboard_view_model.dart';

class StudentDashboardView extends StatefulWidget {
  const StudentDashboardView({
    required this.user,
    required this.incidentService,
    required this.studentProfileService,
    required this.broadcastService,
    required this.onSignOut,
    super.key,
  });

  final AppUser user;
  final IncidentService incidentService;
  final StudentProfileService studentProfileService;
  final BroadcastService broadcastService;
  final Future<void> Function() onSignOut;

  @override
  State<StudentDashboardView> createState() => _StudentDashboardViewState();
}

class _StudentDashboardViewState extends State<StudentDashboardView> {
  late final StudentDashboardViewModel _viewModel;
  late final SosViewModel _sosViewModel;
  late final StudentProfileViewModel _profileViewModel;
  late final IncidentHistoryViewModel _historyViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = StudentDashboardViewModel(widget.broadcastService);
    _sosViewModel = SosViewModel(
      incidentService: widget.incidentService,
      profileId: widget.user.id,
    );
    _historyViewModel = IncidentHistoryViewModel(
      incidentService: widget.incidentService,
      profileId: widget.user.id,
    );
    _profileViewModel = StudentProfileViewModel(
      profileService: widget.studentProfileService,
      profileId: widget.user.id,
    );
    _viewModel.loadLatestAnnouncement();
    _sosViewModel.loadEmergencyTypes();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _sosViewModel.dispose();
    _historyViewModel.dispose();
    _profileViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: _viewModel.selectedTab == StudentDashboardTab.home
              ? _DashboardHeader(
                  fullName: widget.user.fullName,
                  onRefresh: _refreshCurrentTab,
                  onSignOut: widget.onSignOut,
                )
              : _SectionHeader(
                  title: _sectionTitle(_viewModel.selectedTab),
                  onBack: () =>
                      _viewModel.selectTab(StudentDashboardTab.home),
                  onRefresh: _refreshCurrentTab,
                  onSignOut: widget.onSignOut,
                ),
          body: switch (_viewModel.selectedTab) {
            StudentDashboardTab.home => _HomeContent(
              viewModel: _viewModel,
            ),
            StudentDashboardTab.history => IncidentHistoryView(
              viewModel: _historyViewModel,
            ),
            StudentDashboardTab.sos => SosView(
              viewModel: _sosViewModel,
              onSubmitted: () =>
                  _viewModel.selectTab(StudentDashboardTab.home),
            ),
            StudentDashboardTab.profile => StudentProfileView(
              viewModel: _profileViewModel,
            ),
          },
          bottomNavigationBar: _StudentBottomNavigation(
            selectedTab: _viewModel.selectedTab,
            onSelected: _viewModel.selectTab,
          ),
        );
      },
    );
  }

  String _sectionTitle(StudentDashboardTab tab) {
    return switch (tab) {
      StudentDashboardTab.home => 'SAGIP',
      StudentDashboardTab.history => 'Incident History',
      StudentDashboardTab.sos => 'SOS',
      StudentDashboardTab.profile => 'My Profile',
    };
  }

  Future<void> _refreshCurrentTab() async {
    switch (_viewModel.selectedTab) {
      case StudentDashboardTab.sos:
        await _sosViewModel.loadEmergencyTypes();
      case StudentDashboardTab.profile:
        await _profileViewModel.loadProfile();
      case StudentDashboardTab.home:
        await _viewModel.loadLatestAnnouncement();
      case StudentDashboardTab.history:
        await _historyViewModel.loadIncidents();
    }
  }
}

class _SectionHeader extends StatelessWidget implements PreferredSizeWidget {
  const _SectionHeader({
    required this.title,
    required this.onBack,
    required this.onRefresh,
    required this.onSignOut,
  });

  final String title;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onSignOut;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF006B2D),
      foregroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
        IconButton(
          tooltip: 'Sign out',
          onPressed: onSignOut,
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    );
  }
}

class _DashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  const _DashboardHeader({
    required this.fullName,
    required this.onRefresh,
    required this.onSignOut,
  });

  static const green = Color(0xFF006B2D);

  final String fullName;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onSignOut;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      backgroundColor: green,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome,',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 2),
          Text(
            fullName.isEmpty ? 'Student' : fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
        IconButton(
          tooltip: 'Sign out',
          onPressed: onSignOut,
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.viewModel});

  final StudentDashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _AnnouncementBoard(
          announcement: viewModel.announcement,
          isLoading: viewModel.isLoadingAnnouncement,
          errorMessage: viewModel.announcementError,
        ),
        const SizedBox(height: 18),
        const Text(
          'Use the bottom menu to submit SOS reports, view incident history, or open your profile.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF656B66), height: 1.4),
        ),
      ],
    );
  }
}

class _AnnouncementBoard extends StatelessWidget {
  const _AnnouncementBoard({
    required this.announcement,
    required this.isLoading,
    required this.errorMessage,
  });

  final DashboardAnnouncement? announcement;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 430),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E4E0)),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 72,
                  color: Color(0xFFB45309),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Announcements unavailable',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF656B66), height: 1.4),
                ),
              ],
            )
          : announcement == null
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.campaign_outlined,
                  size: 76,
                  color: Color(0xFFB9BFB9),
                ),
                SizedBox(height: 18),
                Text(
                  'No announcements yet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'Campus-wide announcements from SSD will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF656B66), height: 1.4),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2B705).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.campaign_outlined,
                        color: Color(0xFFF2B705),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Announcement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  announcement!.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  announcement!.message,
                  style: const TextStyle(fontSize: 15, height: 1.45),
                ),
              ],
            ),
    );
  }
}

class _StudentBottomNavigation extends StatelessWidget {
  const _StudentBottomNavigation({
    required this.selectedTab,
    required this.onSelected,
  });

  static const green = Color(0xFF006B2D);
  static const gold = Color(0xFFF2B705);

  final StudentDashboardTab selectedTab;
  final ValueChanged<StudentDashboardTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 78,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE0E4E0))),
        ),
        child: Row(
          children: [
            _NavigationItem(
              label: 'Home',
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              isSelected: selectedTab == StudentDashboardTab.home,
              onTap: () => onSelected(StudentDashboardTab.home),
            ),
            _NavigationItem(
              label: 'History',
              icon: Icons.history_rounded,
              selectedIcon: Icons.history_rounded,
              isSelected: selectedTab == StudentDashboardTab.history,
              onTap: () => onSelected(StudentDashboardTab.history),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -13),
                child: InkResponse(
                  onTap: () => onSelected(StudentDashboardTab.sos),
                  radius: 34,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: gold,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sos_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const Text(
                        'SOS',
                        style: TextStyle(
                          color: green,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _NavigationItem(
              label: 'Profile',
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              isSelected: selectedTab == StudentDashboardTab.profile,
              onTap: () => onSelected(StudentDashboardTab.profile),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? const Color(0xFF006B2D)
        : const Color(0xFF2F3330);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? selectedIcon : icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

