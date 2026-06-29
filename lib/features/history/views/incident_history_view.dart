import 'package:flutter/material.dart';

import '../models/student_incident.dart';
import '../viewmodels/incident_history_view_model.dart';

class IncidentHistoryView extends StatefulWidget {
  const IncidentHistoryView({required this.viewModel, super.key});

  final IncidentHistoryViewModel viewModel;

  @override
  State<IncidentHistoryView> createState() => _IncidentHistoryViewState();
}

class _IncidentHistoryViewState extends State<IncidentHistoryView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadIncidents();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final viewModel = widget.viewModel;

        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return _HistoryMessage(
            icon: Icons.error_outline_rounded,
            title: 'History unavailable',
            message: viewModel.errorMessage!,
            action: TextButton.icon(
              onPressed: viewModel.loadIncidents,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          );
        }

        if (viewModel.incidents.isEmpty) {
          return const _HistoryMessage(
            icon: Icons.assignment_outlined,
            title: 'No incidents yet',
            message: 'Your submitted SOS reports will appear here.',
          );
        }

        return RefreshIndicator(
          onRefresh: viewModel.loadIncidents,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            itemBuilder: (context, index) {
              return _IncidentHistoryCard(incident: viewModel.incidents[index]);
            },
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemCount: viewModel.incidents.length,
          ),
        );
      },
    );
  }
}

class _IncidentHistoryCard extends StatelessWidget {
  const _IncidentHistoryCard({required this.incident});

  final StudentIncident incident;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFE0E4E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: _statusColor(incident.status).withValues(
                alpha: 0.12,
              ),
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
                  const SizedBox(height: 5),
                  Text(_formatDateTime(incident.createdAt)),
                  const SizedBox(height: 5),
                  Text(
                    incident.location?.trim().isNotEmpty == true
                        ? incident.location!.trim()
                        : 'Location capture will be connected later.',
                    style: const TextStyle(color: Color(0xFF656B66)),
                  ),
                  if (incident.description?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(incident.description!.trim()),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            _StatusPill(status: incident.status),
          ],
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

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

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
            if (action != null) ...[
              const SizedBox(height: 10),
              action!,
            ],
          ],
        ),
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
  final hour = value.hour == 0
      ? 12
      : value.hour > 12
      ? value.hour - 12
      : value.hour;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '${months[value.month - 1]} ${value.day}, ${value.year} $hour:$minute $period';
}
