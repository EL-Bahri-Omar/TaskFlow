class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String color;
  final List<Map<String, dynamic>> members;
  final Map<String, dynamic>? createdBy;
  final int taskCount;
  final int doneCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectModel({
    required this.id,
    required this.name,
    this.description = '',
    this.color = '#009688',
    this.members = const [],
    this.createdBy,
    this.taskCount = 0,
    this.doneCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      color: json['color'] as String? ?? '#009688',
      members: (json['members'] as List<dynamic>?)
              ?.map((m) => m is Map<String, dynamic> ? m : <String, dynamic>{})
              .toList() ??
          [],
      createdBy: json['createdBy'] is Map<String, dynamic> ? json['createdBy'] : null,
      taskCount: json['taskCount'] as int? ?? 0,
      doneCount: json['doneCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'color': color,
      'members': members.map((m) => m['_id']).toList(),
    };
  }

  // Helper getters
  double get progress => taskCount > 0 ? doneCount / taskCount : 0.0;
  String get createdByName => createdBy?['name'] ?? 'Unknown';
}
