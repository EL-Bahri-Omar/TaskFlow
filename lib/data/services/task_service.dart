import 'package:flutter_app/data/models/task_model.dart';
import 'package:flutter_app/data/services/api_service.dart';
import 'package:flutter_app/data/notifiers.dart';

class TaskService {
  static Future<List<TaskModel>> getTasks({String? status, String? project}) async {
    String endpoint = '/tasks';
    List<String> params = [];
    if (status != null) params.add('status=$status');
    if (project != null) params.add('project=$project');
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';

    final data = await ApiService.get(endpoint);
    final tasks = (data as List).map((json) => TaskModel.fromJson(json)).toList();
    tasksNotifier.value = tasks;
    return tasks;
  }

  static Future<Map<String, int>> getStats() async {
    final data = await ApiService.get('/tasks/stats');
    final stats = {
      'total': data['total'] as int,
      'todo': data['todo'] as int,
      'inProgress': data['inProgress'] as int,
      'done': data['done'] as int,
    };
    taskStatsNotifier.value = stats;
    return stats;
  }

  static Future<TaskModel> getTask(String id) async {
    final data = await ApiService.get('/tasks/$id');
    return TaskModel.fromJson(data);
  }

  static Future<TaskModel> createTask(Map<String, dynamic> taskData) async {
    final data = await ApiService.post('/tasks', taskData);
    final task = TaskModel.fromJson(data);

    // Refresh tasks list
    await getTasks();
    await getStats();

    return task;
  }

  static Future<TaskModel> updateTask(String id, Map<String, dynamic> taskData) async {
    final data = await ApiService.put('/tasks/$id', taskData);
    final task = TaskModel.fromJson(data);

    // Refresh tasks list
    await getTasks();
    await getStats();

    return task;
  }

  static Future<void> deleteTask(String id) async {
    await ApiService.delete('/tasks/$id');

    // Refresh tasks list
    await getTasks();
    await getStats();
  }
}
