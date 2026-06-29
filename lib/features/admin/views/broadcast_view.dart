import 'package:flutter/material.dart';

import '../../broadcast/models/broadcast_message.dart';
import '../../broadcast/viewmodels/broadcast_view_model.dart';

class BroadcastView extends StatefulWidget {
  const BroadcastView({required this.viewModel, super.key});

  final BroadcastViewModel viewModel;

  @override
  State<BroadcastView> createState() => _BroadcastViewState();
}

class _BroadcastViewState extends State<BroadcastView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadRecentBroadcasts();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final sent = await widget.viewModel.sendBroadcast(
      title: _titleController.text,
      message: _messageController.text,
    );
    if (!sent) return;
    _titleController.clear();
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final viewModel = widget.viewModel;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF006B2D),
            foregroundColor: Colors.white,
            title: const Text('Broadcast'),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: viewModel.isLoading
                    ? null
                    : viewModel.loadRecentBroadcasts,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Text(
                'Create Broadcast',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              if (viewModel.errorMessage != null)
                _MessageCard(
                  message: viewModel.errorMessage!,
                  color: const Color(0xFFFFE4E4),
                ),
              if (viewModel.successMessage != null)
                _MessageCard(
                  message: viewModel.successMessage!,
                  color: const Color(0xFFE7F8EC),
                ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      enabled: !viewModel.isSending,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter title',
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _messageController,
                      enabled: !viewModel.isSending,
                      minLines: 5,
                      maxLines: 8,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        hintText: 'Enter your message...',
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 88),
                          child: Icon(Icons.message_outlined),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Message is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 6),
                    FilledButton.icon(
                      onPressed: viewModel.isSending ? null : _send,
                      icon: viewModel.isSending
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.campaign_outlined),
                      label: const Text('SEND BROADCAST'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Broadcasts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (viewModel.recentBroadcasts.isEmpty)
                const _EmptyBroadcastsView()
              else
                ...viewModel.recentBroadcasts.map(
                  (broadcast) => _BroadcastCard(broadcast: broadcast),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BroadcastCard extends StatelessWidget {
  const _BroadcastCard({required this.broadcast});

  final BroadcastMessage broadcast;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.campaign_outlined),
        title: Text(
          broadcast.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${broadcast.message}\n${_formatDateTime(broadcast.createdAt)}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(message),
      ),
    );
  }
}

class _EmptyBroadcastsView extends StatelessWidget {
  const _EmptyBroadcastsView();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Text('No broadcasts yet. Sent broadcasts will appear here.'),
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  final hour = value.hour == 0
      ? 12
      : value.hour > 12
      ? value.hour - 12
      : value.hour;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '${value.month}/${value.day}/${value.year} $hour:$minute $period';
}
