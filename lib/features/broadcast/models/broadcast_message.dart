class BroadcastMessage {
  const BroadcastMessage({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;

  factory BroadcastMessage.fromJson(Map<String, dynamic> json) {
    return BroadcastMessage(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}
