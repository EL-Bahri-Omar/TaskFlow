import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models/task_model.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/views/pages/task_detail_page.dart';
import 'package:flutter_app/views/pages/task_view_page.dart';
import 'package:flutter_app/views/widgets/status_badge_widget.dart';
import 'package:intl/intl.dart';

class TaskCardWidget extends StatelessWidget {
  const TaskCardWidget({super.key, required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final currentUserId = currentUserNotifier.value?.id;
    final isCreator = task.createdBy?['_id'] == currentUserId;
    final isAssignedToMe = task.assignedTo?['_id'] == currentUserId;
    final assigneeAvatar = task.assignedTo?['avatar'] as String?;
    final assigneeName = task.assignedToName;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (isCreator) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailPage(task: task),
              ),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskViewPage(task: task)),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    KPriority.icon(task.priority),
                    color: KPriority.color(task.priority),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: task.status == KTaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  StatusBadgeWidget(status: task.status),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                SizedBox(height: 6),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
              SizedBox(height: 8),
              Row(
                children: [
                  if (task.project != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(
                            task.projectColor.replaceFirst('#', '0xFF'),
                          ),
                        ).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.projectName,
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                    SizedBox(width: 2),
                  ],
                  // User avatar
                  buildMemberAvatar(assigneeAvatar, assigneeName, 10),
                  SizedBox(width: 2),
                  Text(
                    isAssignedToMe ? 'Me' : assigneeName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isAssignedToMe ? Colors.teal : Colors.grey,
                      fontWeight: isAssignedToMe
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Spacer(),
                  if (task.dueDate != null) ...[
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    SizedBox(width: 1),
                    Text(
                      DateFormat('MMM dd').format(task.dueDate!),
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            task.dueDate!.isBefore(DateTime.now()) &&
                                task.status != KTaskStatus.done
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared helper: renders avatar image from base64 or first-letter fallback
Widget buildMemberAvatar(String? avatarBase64, String name, double radius) {
  // Check if avatar is a valid base64 string (not empty or just a short placeholder)
  final hasAvatar =
      avatarBase64 != null &&
      avatarBase64.isNotEmpty &&
      avatarBase64.length > 100;

  if (hasAvatar) {
    try {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(base64Decode(avatarBase64)),
      );
    } catch (_) {
      // Fall through to letter avatar if decode fails
    }
  }

  return CircleAvatar(
    radius: radius,
    backgroundColor: Colors.teal,
    child: Text(
      (name.isNotEmpty ? name[0] : 'U').toUpperCase(),
      style: TextStyle(
        color: Colors.white,
        fontSize: radius * 0.8,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
