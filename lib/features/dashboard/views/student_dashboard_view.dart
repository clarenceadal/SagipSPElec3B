import 'package:flutter/material.dart';

import '../../auth/models/app_user.dart';
import '../../sos/services/incident_service.dart';
import '../../sos/viewmodels/sos_view_model.dart';
import '../../sos/views/sos_view.dart';
import '../viewmodels/student_dashboard_view_model.dart';

class StudentDashboardView extends StatefulWidget {
  const StudentDashboardView({
    required this.user,
    required this.incidentService,
    required this.onSignOut,
    super.key,
  });

  final AppUser user;
  final IncidentService incidentService;
  final Future<void> Function() onSignOut;

  @override
  State<StudentDashboardView> createState() => _StudentDashboardViewState();
}

class _StudentDashboardViewState extends State<StudentDashboardView> {
  late final StudentDashboardViewModel _viewModel;
  late final SosViewModel _sosViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = StudentDashboardViewModel();
    _sosViewModel = SosViewModel(
      incidentService: widget.incidentService,
      profileId: widget.user.id,
    );
    _sosViewModel.loadEmergencyTypes();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _sosViewModel.dispose();
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
                  onSignOut: widget.onSignOut,
                )
              : _SectionHeader(
                  title: _sectionTitle(_viewModel.selectedTab),
                  onBack: () =>
                      _viewModel.selectTab(StudentDashboardTab.home),
                ),
          drawer: _StudentDrawer(
            fullName: widget.user.fullName,
            email: widget.user.email,
            onSignOut: widget.onSignOut,
          ),
          body: switch (_viewModel.selectedTab) {
            StudentDashboardTab.home => _HomeContent(
              viewModel: _viewModel,
            ),
            StudentDashboardTab.history => const _PendingModuleView(
              icon: Icons.history_rounded,
              title: 'Incident History',
              message: 'Your submitted incidents will appear here.',
            ),
            StudentDashboardTab.sos => SosView(
              viewModel: _sosViewModel,
              onSubmitted: () =>
                  _viewModel.selectTab(StudentDashboardTab.home),
            ),
            StudentDashboardTab.profile => const _PendingModuleView(
              icon: Icons.person_outline_rounded,
              title: 'My Profile',
              message: 'Your student profile will appear here.',
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
}

class _SectionHeader extends StatelessWidget implements PreferredSizeWidget {
  const _SectionHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

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
    );
  }
}

class _StudentDrawer extends StatelessWidget {
  const _StudentDrawer({
    required this.fullName,
    required this.email,
    required this.onSignOut,
  });

  final String fullName;
  final String email;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF006B2D),
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_rounded,
                      color: Color(0xFF006B2D),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    fullName.isEmpty ? 'Student' : fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    email,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () {
                Navigator.of(context).pop();
                onSignOut();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  const _DashboardHeader({
    required this.fullName,
    required this.onSignOut,
  });

  static const green = Color(0xFF006B2D);

  final String fullName;
  final Future<void> Function() onSignOut;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      backgroundColor: green,
      foregroundColor: Colors.white,
      leading: Builder(
        builder: (context) {
          return IconButton(
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded, size: 30),
          );
        },
      ),
      titleSpacing: 4,
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
          tooltip: 'Notifications',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Student notifications will be added next.'),
              ),
            );
          },
          icon: const Icon(Icons.notifications_rounded),
        ),
        PopupMenuButton<String>(
          tooltip: 'Account',
          onSelected: (value) {
            if (value == 'sign_out') onSignOut();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'sign_out',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 10),
                  Text('Sign out'),
                ],
              ),
            ),
          ],
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
        _DashboardCard(
          icon: Icons.campaign_outlined,
          title: 'Announcements',
          accentColor: const Color(0xFFF2B705),
          onTap: null,
          child: viewModel.announcement == null
              ? const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No new announcements'),
                    SizedBox(height: 8),
                    Text(
                      'Stay safe!',
                      style: TextStyle(color: Color(0xFF656B66)),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.announcement!.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(viewModel.announcement!.message),
                  ],
                ),
        ),
        const SizedBox(height: 14),
        _DashboardCard(
          icon: Icons.health_and_safety_outlined,
          title: 'Quick Actions',
          accentColor: const Color(0xFFF2B705),
          onTap: viewModel.openSos,
          child: const Text(
            'Press the SOS button if you need immediate help.',
          ),
        ),
        const SizedBox(height: 14),
        _DashboardCard(
          icon: Icons.history_rounded,
          title: 'Incident History',
          accentColor: const Color(0xFFF2B705),
          outlined: true,
          onTap: viewModel.openHistory,
          child: const Text(
            'View your previous incidents and their current status.',
          ),
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.child,
    required this.onTap,
    this.outlined = false,
  });

  final IconData icon;
  final String title;
  final Color accentColor;
  final Widget child;
  final VoidCallback? onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: outlined ? accentColor : const Color(0xFFE0E4E0),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DefaultTextStyle(
                      style: const TextStyle(
                        color: Color(0xFF343834),
                        fontSize: 14,
                        height: 1.35,
                      ),
                      child: child,
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Icon(Icons.chevron_right_rounded),
                ),
              ],
            ],
          ),
        ),
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

class _PendingModuleView extends StatelessWidget {
  const _PendingModuleView({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

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
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF656B66)),
            ),
          ],
        ),
      ),
    );
  }
}
