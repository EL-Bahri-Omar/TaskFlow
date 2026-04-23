import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models/task_model.dart';
import 'package:flutter_app/data/services/task_service.dart';
import 'package:flutter_app/views/widgets/status_badge_widget.dart';
import 'package:intl/intl.dart';

/// Read-only task view for assigned members — can only update status.
class TaskViewPage extends StatefulWidget {
  final TaskModel task;

  const TaskViewPage({super.key, required this.task});

  @override
  State<TaskViewPage> createState() => _TaskViewPageState();
}

class _TaskViewPageState extends State<TaskViewPage> {
  late String _status;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _status = widget.task.status;
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              task.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            // Status & Priority row
            Row(
              children: [
                StatusBadgeWidget(status: _status),
                SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: KPriority.color(task.priority).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(KPriority.icon(task.priority),
                          size: 14, color: KPriority.color(task.priority)),
                      SizedBox(width: 4),
                      Text(KPriority.label(task.priority),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                              color: KPriority.color(task.priority))),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Description
            if (task.description.isNotEmpty) ...[
              Text('Description', style: KTextStyle.titleTealText),
              SizedBox(height: 8),
              Text(task.description, style: TextStyle(fontSize: 15)),
              SizedBox(height: 20),
            ],

            // Info cards
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(Icons.person, 'Created by', task.createdByName),
                    Divider(),
                    _infoRow(Icons.person_outline, 'Assigned to', task.assignedToName),
                    Divider(),
                    _infoRow(Icons.folder, 'Project', task.projectName),
                    if (task.dueDate != null) ...[
                      Divider(),
                      _infoRow(Icons.calendar_today, 'Due date',
                          DateFormat('MMM dd, yyyy').format(task.dueDate!)),
                    ],
                    Divider(),
                    _infoRow(Icons.access_time, 'Created',
                        DateFormat('MMM dd, yyyy').format(task.createdAt)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Status update section
            Text('Update Status', style: KTextStyle.titleTealText),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _status,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              decoration: InputDecoration(
                prefixIcon: Icon(KTaskStatus.icon(_status)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              items: KTaskStatus.all.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(KTaskStatus.icon(status),
                          color: KTaskStatus.color(status), size: 20),
                      SizedBox(width: 8),
                      Text(KTaskStatus.label(status)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _status = value!);
              },
            ),
            SizedBox(height: 16),
            _isUpdating
                ? Center(child: CircularProgressIndicator())
                : FilledButton(
                    onPressed: _status != widget.task.status ? _updateStatus : null,
                    style: FilledButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                    ),
                    child: Text('Save Status', style: TextStyle(fontSize: 16)),
                  ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: Colors.grey)),
          Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Future<void> _updateStatus() async {
    setState(() => _isUpdating = true);
    try {
      await TaskService.updateTask(widget.task.id, {'status': _status});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated'), behavior: SnackBarBehavior.floating),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')),
              behavior: SnackBarBehavior.floating, backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }
}
