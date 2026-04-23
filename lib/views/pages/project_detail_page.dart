import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models/project_model.dart';
import 'package:flutter_app/data/models/task_model.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/data/services/api_service.dart';
import 'package:flutter_app/data/services/project_service.dart';
import 'package:flutter_app/views/pages/task_detail_page.dart';
import 'package:flutter_app/views/widgets/task_card_widget.dart';

class ProjectDetailPage extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  late ProjectModel _project;
  List<TaskModel> _tasks = [];
  bool _isLoading = true;
  bool _membersExpanded = false;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _loadProjectDetail();
  }

  Future<void> _loadProjectDetail() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get('/projects/${_project.id}');
      _project = ProjectModel.fromJson(data);

      if (data['tasks'] != null) {
        _tasks = (data['tasks'] as List)
            .map((json) => TaskModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = currentUserNotifier.value?.id;
    final isCreator = _project.createdBy?['_id'] == currentUserId;
    final projectColor = Color(
      int.parse(_project.color.replaceFirst('#', '0xFF')),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_project.name),
        actions: [
          if (isCreator)
            IconButton(
              onPressed: _deleteProject,
              icon: Icon(Icons.delete, color: Colors.red),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProjectDetail,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project info card
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: projectColor,
                                  child: Icon(Icons.folder, color: Colors.white),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _project.name,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text('Created by ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                          buildMemberAvatar(
                                            _project.createdBy?['avatar'] as String?,
                                            _project.createdByName,
                                            8,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            _project.createdByName,
                                            style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (_project.description.isNotEmpty) ...[
                              SizedBox(height: 12),
                              Text(_project.description, style: KTextStyle.descriptionText),
                            ],
                            SizedBox(height: 16),
                            // Progress bar
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: _project.taskCount > 0
                                          ? _project.doneCount / _project.taskCount
                                          : 0.0,
                                      backgroundColor: Colors.grey.withValues(alpha: 0.3),
                                      valueColor: AlwaysStoppedAnimation<Color>(projectColor),
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  _project.taskCount > 0
                                      ? '${(_project.doneCount / _project.taskCount * 100).toInt()}%'
                                      : '0%',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${_project.doneCount}/${_project.taskCount} tasks completed',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Members section with expandable list
                    Card(
                      child: Column(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() => _membersExpanded = !_membersExpanded);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(Icons.group, color: Colors.teal),
                                  SizedBox(width: 12),
                                  Text(
                                    'Members (${_project.members.length})',
                                    style: KTextStyle.titleTealText,
                                  ),
                                  Spacer(),
                                  Icon(
                                    _membersExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_membersExpanded)
                            Padding(
                              padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                              child: Column(
                                children: _project.members.map((member) {
                                  final memberName = member['name'] as String? ?? 'Unknown';
                                  final memberEmail = member['email'] as String? ?? '';
                                  final memberAvatar = member['avatar'] as String?;
                                  final isProjectCreator = member['_id'] == _project.createdBy?['_id'];

                                  return Card(
                                    margin: EdgeInsets.only(bottom: 4),
                                    child: ListTile(
                                      leading: buildMemberAvatar(memberAvatar, memberName, 20),
                                      title: Text(
                                        memberName,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(memberEmail, style: TextStyle(fontSize: 12)),
                                      trailing: isProjectCreator
                                          ? Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.teal.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Creator',
                                                style: TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold),
                                              ),
                                            )
                                          : null,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Tasks in this project
                    Text("Tasks (${_tasks.length})", style: KTextStyle.titleTealText),
                    SizedBox(height: 10),
                    if (_tasks.isEmpty)
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: Text("No tasks in this project yet",
                                style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      )
                    else
                      ..._tasks.map((task) => TaskCardWidget(task: task)),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: isCreator
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskDetailPage()),
                );
                if (result == true) _loadProjectDetail();
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _deleteProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Project"),
          content: Text("Are you sure? This will also delete all tasks in this project."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await ProjectService.deleteProject(_project.id);
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
