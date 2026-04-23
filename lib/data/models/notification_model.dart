class NotificationModel {
  final String id;
  final String recipient;
  final String message;
  final Map<String, dynamic>? task;
  final bool read;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.recipient,
    required this.message,
    this.task,
    this.read = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] as String,
      recipient: json['recipient'] is String
          ? json['recipient']
          : json['recipient']['_id'] as String,
      message: json['message'] as String,
      task: json['task'] is Map<String, dynamic> ? json['task'] : null,
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
