import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/data/services/task_service.dart';
import 'package:flutter_app/data/services/project_service.dart';
import 'package:flutter_app/views/pages/task_detail_page.dart';
import 'package:flutter_app/views/widgets/task_card_widget.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _selectedStatusFilter = 'all';
  String? _selectedProjectFilter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await ProjectService.getProjects();
      await _loadTasks();
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTasks() async {
    try {
      String? status = _selectedStatusFilter == 'all' ? null : _selectedStatusFilter;
      await TaskService.getTasks(status: status, project: _selectedProjectFilter);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Status filter chips
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  SizedBox(width: 8.0),
                  _buildFilterChip('To Do', KTaskStatus.todo),
                  SizedBox(width: 8.0),
                  _buildFilterChip('In Progress', KTaskStatus.inProgress),
                  SizedBox(width: 8.0),
                  _buildFilterChip('Done', KTaskStatus.done),
                ],
              ),
            ),
          ),

          // Project filter dropdown
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: ValueListenableBuilder(
              valueListenable: projectsNotifier,
              builder: (context, projects, child) {
                return DropdownButtonFormField<String?>(
                  initialValue: _selectedProjectFilter,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Filter by Project',
                    prefixIcon: Icon(Icons.folder, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Projects'),
                    ),
                    ...projects.map((project) {
                      return DropdownMenuItem<String?>(
                        value: project.id,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 8,
                              backgroundColor: Color(
                                int.parse(project.color.replaceFirst('#', '0xFF')),
                              ),
                            ),
                            SizedBox(width: 8),
                            Flexible(child: Text(project.name, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedProjectFilter = value;
                    });
                    _loadTasks().then((_) {
                      if (mounted) setState(() {});
                    });
                  },
                );
              },
            ),
          ),
          SizedBox(height: 8),

          // Tasks list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ValueListenableBuilder(
                      valueListenable: tasksNotifier,
                      builder: (context, tasks, child) {
                        if (tasks.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.task_alt, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text("No tasks found",
                                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                                SizedBox(height: 8),
                                Text("Tap + to create a new task",
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            return TaskCardWidget(task: tasks[index]);
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailPage(),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatusFilter = value;
        });
        _loadTasks().then((_) {
          if (mounted) setState(() {});
        });
      },
      selectedColor: Colors.teal.withValues(alpha: 0.3),
      checkmarkColor: Colors.teal,
    );
  }
}
