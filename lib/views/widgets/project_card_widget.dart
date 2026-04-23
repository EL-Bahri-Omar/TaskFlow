import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/project_model.dart';
import 'package:flutter_app/views/widgets/task_card_widget.dart';

class ProjectCardWidget extends StatelessWidget {
  const ProjectCardWidget({
    super.key,
    required this.project,
    this.onTap,
  });

  final ProjectModel project;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final projectColor = Color(
      int.parse(project.color.replaceFirst('#', '0xFF')),
    );

    // Creator info
    final creatorName = project.createdByName;
    final creatorAvatar = project.createdBy?['avatar'] as String?;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: projectColor,
                    child: Icon(Icons.folder, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (project.description.isNotEmpty)
                          Text(
                            project.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: project.progress,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(projectColor),
                  minHeight: 6,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.task_alt, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${project.doneCount}/${project.taskCount} tasks',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Spacer(),
                  // Creator avatar + name
                  buildMemberAvatar(creatorAvatar, creatorName, 10),
                  SizedBox(width: 4),
                  Text(
                    creatorName,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
