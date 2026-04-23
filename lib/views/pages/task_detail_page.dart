import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models/task_model.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/data/services/task_service.dart';
import 'package:flutter_app/data/services/project_service.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:intl/intl.dart';

class TaskDetailPage extends StatefulWidget {
  final TaskModel? task;

  const TaskDetailPage({super.key, this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _status = KTaskStatus.todo;
  String _priority = KPriority.medium;
  DateTime? _dueDate;
  String? _selectedProjectId;
  String? _selectedUserId;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.task != null;
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _status = widget.task!.status;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
      _selectedProjectId = widget.task!.project?['_id'];
      _selectedUserId = widget.task!.assignedTo?['_id'];
    }
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      await ProjectService.getProjects();
      await AuthService.getUsers();
    } catch (e) {
      // Ignore
    }
    if (mounted) setState(() => _dataLoaded = true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _deleteTask,
              icon: Icon(Icons.delete, color: Colors.red),
            ),
        ],
      ),
      body: !_dataLoaded
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        hintText: 'Enter task title',
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),

                    // Description
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter task description',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(12),
                      decoration: InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(KTaskStatus.icon(_status)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      items: KTaskStatus.all.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                KTaskStatus.icon(status),
                                color: KTaskStatus.color(status),
                                size: 20,
                              ),
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
                    SizedBox(height: 15.0),

                    // Priority Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _priority,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(12),
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: Icon(KPriority.icon(_priority)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      items: KPriority.all.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                KPriority.icon(priority),
                                color: KPriority.color(priority),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(KPriority.label(priority)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _priority = value!);
                      },
                    ),
                    SizedBox(height: 15.0),

                    // Due Date
                    InkWell(
                      onTap: _pickDueDate,
                      borderRadius: BorderRadius.circular(15.0),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Due Date',
                          prefixIcon: Icon(Icons.calendar_today, color: Colors.teal),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_dueDate != null)
                                IconButton(
                                  icon: Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    setState(() => _dueDate = null);
                                  },
                                ),
                              IconButton(
                                icon: Icon(Icons.edit_calendar),
                                onPressed: _pickDueDate,
                              ),
                            ],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        child: Text(
                          _dueDate != null
                              ? DateFormat('MMM dd, yyyy').format(_dueDate!)
                              : 'No due date',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),

                    // Project (only show projects created by current user)
                    _buildProjectDropdown(),
                    SizedBox(height: 15.0),

                    // Assign to user
                    ValueListenableBuilder(
                      valueListenable: allUsersNotifier,
                      builder: (context, users, child) {
                        return DropdownButtonFormField<String?>(
                          initialValue: _selectedUserId,
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(12),
                          decoration: InputDecoration(
                            labelText: 'Assign To',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Unassigned'),
                            ),
                            ...users.map((user) {
                              return DropdownMenuItem<String?>(
                                value: user.id,
                                child: Text(user.name),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedUserId = value);
                          },
                        );
                      },
                    ),
                    SizedBox(height: 30.0),

                    // Save Button
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : FilledButton(
                            onPressed: _saveTask,
                            style: FilledButton.styleFrom(
                              minimumSize: Size(double.infinity, 48.0),
                            ),
                            child: Text(
                              _isEditing ? 'Update Task' : 'Create Task',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                    SizedBox(height: 50.0),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProjectDropdown() {
    return ValueListenableBuilder(
      valueListenable: projectsNotifier,
      builder: (context, projects, child) {
        final currentUserId = currentUserNotifier.value?.id;
        final myProjects = projects
            .where((p) => p.createdBy?['_id'] == currentUserId)
            .toList();

        String? effectiveProjectId = _selectedProjectId;
        if (effectiveProjectId != null &&
            !myProjects.any((p) => p.id == effectiveProjectId)) {
          effectiveProjectId = null;
        }

        return DropdownButtonFormField<String?>(
          initialValue: effectiveProjectId,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          decoration: InputDecoration(
            labelText: 'Project',
            prefixIcon: Icon(Icons.folder),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          items: [
            DropdownMenuItem<String?>(value: null, child: Text('No Project')),
            ...myProjects.map((project) {
              return DropdownMenuItem<String?>(
                value: project.id,
                child: Text(project.name),
              );
            }),
          ],
          onChanged: (value) {
            setState(() => _selectedProjectId = value);
          },
        );
      },
    );
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  Future<void> _saveTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a task title'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final taskData = <String, dynamic>{
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'status': _status,
        'priority': _priority,
        'dueDate': _dueDate?.toIso8601String(),
        'assignedTo': _selectedUserId,
      };

      // Only include project if user explicitly selected one
      // This prevents overwriting with null when editing someone else's project task
      if (_selectedProjectId != null) {
        taskData['project'] = _selectedProjectId;
      }

      if (_isEditing) {
        await TaskService.updateTask(widget.task!.id, taskData);
      } else {
        taskData['project'] = _selectedProjectId;
        await TaskService.createTask(taskData);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Task"),
          content: Text("Are you sure you want to delete this task?"),
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
        await TaskService.deleteTask(widget.task!.id);
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
