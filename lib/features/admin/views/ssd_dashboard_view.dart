import 'package:flutter/material.dart';

import '../../auth/models/app_user.dart';
import '../../broadcast/services/broadcast_service.dart';
import '../../broadcast/viewmodels/broadcast_view_model.dart';
import '../../sos/services/incident_service.dart';
import '../models/admin_incident.dart';
import '../viewmodels/ssd_dashboard_view_model.dart';
import 'broadcast_view.dart';

class SsdDashboardView extends StatefulWidget {
  const SsdDashboardView({
    required this.user,
    required this.incidentService,
    required this.broadcastService,
    required this.onSignOut,
    super.key,
  });

  final AppUser user;
  final IncidentService incidentService;
  final BroadcastService broadcastService;
  final Future<void> Function() onSignOut;

  @override
  State<SsdDashboardView> createState() => _SsdDashboardViewState();
}

class _SsdDashboardViewState extends State<SsdDashboardView> {
  late final SsdDashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SsdDashboardViewModel(widget.incidentService);
    _viewModel.loadIncidents();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF006B2D),
            foregroundColor: Colors.white,
            title: const Text('SSD Dashboard'),
            actions: [
              IconButton(
                tooltip: 'Broadcast',
                onPressed: _openBroadcast,
                icon: const Icon(Icons.campaign_outlined),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: _viewModel.isLoading
                    ? null
                    : _viewModel.loadIncidents,
                icon: const Icon(Icons.refresh_rounded),
              ),
              IconButton(
                tooltip: 'Sign out',
                onPressed: widget.onSignOut,
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _viewModel.loadIncidents,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                Text(
                  'Welcome, ${widget.user.fullName.isEmpty ? 'SSD Admin' : widget.user.fullName}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                if (_viewModel.errorMessage != null)
                  _ErrorCard(message: _viewModel.errorMessage!),
                _DashboardStats(viewModel: _viewModel),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      'Emergency Reports',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text('${_viewModel.incidents.length} total'),
                  ],
                ),
                const SizedBox(height: 10),
                if (_viewModel.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_viewModel.incidents.isEmpty)
                  const _EmptyIncidentsView()
                else
                  ..._viewModel.incidents.map(
                    (incident) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _IncidentCard(
                        incident: incident,
                        onTap: () => _openIncidentDetails(incident),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openIncidentDetails(AdminIncident incident) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Incident Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                _DetailRow('Emergency Type', incident.emergencyType),
                _DetailRow('Student Name', incident.studentName),
                _DetailRow('Student ID', incident.studentId),
                _DetailRow(
                  'Course / Year',
                  '${incident.course ?? 'N/A'} / Year ${incident.yearLevel ?? '-'}',
                ),
                _DetailRow('Location', incident.location),
                _DetailRow('Timestamp', _formatDateTime(incident.createdAt)),
                _DetailRow('Status', _statusLabel(incident.status)),
                _DetailRow(
                  'Additional Details',
                  incident.description?.trim().isNotEmpty == true
                      ? incident.description!.trim()
                      : 'No additional details.',
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusButton(
                      label: 'ACKNOWLEDGE',
                      color: const Color(0xFFF2B705),
                      onPressed: () => _changeStatus(incident, 'acknowledged'),
                    ),
                    _StatusButton(
                      label: 'RESPONDING',
                      color: const Color(0xFFF2B705),
                      onPressed: () => _changeStatus(incident, 'responding'),
                    ),
                    _StatusButton(
                      label: 'RESOLVED',
                      color: const Color(0xFF006B2D),
                      textColor: Colors.white,
                      onPressed: () => _changeStatus(incident, 'resolved'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _changeStatus(AdminIncident incident, String status) {
    Navigator.of(context).pop();
    _viewModel.updateIncidentStatus(incident.id, status);
  }

  void _openBroadcast() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BroadcastView(
          viewModel: BroadcastViewModel(widget.broadcastService),
        ),
      ),
    );
  }
}

class _DashboardStats extends StatelessWidget {
  const _DashboardStats({required this.viewModel});

  final SsdDashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.9,
      children: [
        _StatCard(
          label: 'Total Incidents',
          value: viewModel.totalIncidents,
          color: const Color(0xFF006B2D),
        ),
        _StatCard(
          label: 'Active Incidents',
          value: viewModel.activeIncidents,
          color: const Color(0xFFE85D04),
        ),
        _StatCard(
          label: 'Responding',
          value: viewModel.respondingIncidents,
          color: const Color(0xFFF2B705),
        ),
        _StatCard(
          label: 'Resolved',
          value: viewModel.resolvedIncidents,
          color: const Color(0xFF006B2D),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E4E0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  const _IncidentCard({required this.incident, required this.onTap});

  final AdminIncident incident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFE0E4E0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _statusColor(
                  incident.status,
                ).withValues(alpha: 0.12),
                child: Icon(
                  _incidentIcon(incident.emergencyType),
                  color: _statusColor(incident.status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.emergencyType,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      incident.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      incident.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF656B66)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(incident.createdAt),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  _StatusPill(status: incident.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 122,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.label,
    required this.color,
    required this.onPressed,
    this.textColor = Colors.black,
  });

  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFE4E4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(message),
      ),
    );
  }
}

class _EmptyIncidentsView extends StatelessWidget {
  const _EmptyIncidentsView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 72, color: Color(0xFF9AA09B)),
          SizedBox(height: 14),
          Text(
            'No emergency reports yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text('Student SOS requests will appear here.'),
        ],
      ),
    );
  }
}

IconData _incidentIcon(String emergencyType) {
  final value = emergencyType.toLowerCase();
  if (value.contains('fire')) return Icons.local_fire_department_rounded;
  if (value.contains('medical')) return Icons.medical_services_rounded;
  if (value.contains('security') || value.contains('crime')) {
    return Icons.security_rounded;
  }
  if (value.contains('accident')) return Icons.car_crash_rounded;
  if (value.contains('disaster')) return Icons.thunderstorm_rounded;
  return Icons.warning_rounded;
}

Color _statusColor(String status) {
  return switch (status.toLowerCase()) {
    'resolved' => const Color(0xFF006B2D),
    'responding' => const Color(0xFFF2B705),
    'acknowledged' => const Color(0xFF2563EB),
    _ => const Color(0xFFE85D04),
  };
}

String _statusLabel(String status) {
  final value = status.replaceAll('_', ' ').trim();
  if (value.isEmpty) return 'Pending';
  return value
      .split(' ')
      .map((word) {
        if (word.isEmpty) return word;
        return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      })
      .join(' ');
}

String _formatTime(DateTime value) {
  final hour = value.hour == 0
      ? 12
      : value.hour > 12
      ? value.hour - 12
      : value.hour;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

String _formatDateTime(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[value.month - 1]} ${value.day}, ${value.year} ${_formatTime(value)}';
}
