class TaskModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final Map<String, dynamic>? project;
  final Map<String, dynamic>? assignedTo;
  final Map<String, dynamic>? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.status = 'todo',
    this.priority = 'medium',
    this.dueDate,
    this.project,
    this.assignedTo,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'todo',
      priority: json['priority'] as String? ?? 'medium',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      project: json['project'] is Map<String, dynamic> ? json['project'] : null,
      assignedTo: json['assignedTo'] is Map<String, dynamic> ? json['assignedTo'] : null,
      createdBy: json['createdBy'] is Map<String, dynamic> ? json['createdBy'] : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'project': project?['_id'],
      'assignedTo': assignedTo?['_id'],
    };
  }

  // Helper getters
  String get assignedToName => assignedTo?['name'] ?? 'Unassigned';
  String get projectName => project?['name'] ?? 'No Project';
  String get projectColor => project?['color'] ?? '#009688';
  String get createdByName => createdBy?['name'] ?? 'Unknown';
}
