import 'package:flutter_app/data/models/project_model.dart';
import 'package:flutter_app/data/services/api_service.dart';
import 'package:flutter_app/data/notifiers.dart';

class ProjectService {
  static Future<List<ProjectModel>> getProjects() async {
    final data = await ApiService.get('/projects');
    final projects = (data as List).map((json) => ProjectModel.fromJson(json)).toList();
    projectsNotifier.value = projects;
    return projects;
  }

  static Future<ProjectModel> getProject(String id) async {
    final data = await ApiService.get('/projects/$id');
    return ProjectModel.fromJson(data);
  }

  static Future<ProjectModel> createProject(Map<String, dynamic> projectData) async {
    final data = await ApiService.post('/projects', projectData);
    final project = ProjectModel.fromJson(data);

    // Refresh projects list
    await getProjects();

    return project;
  }

  static Future<ProjectModel> updateProject(String id, Map<String, dynamic> projectData) async {
    final data = await ApiService.put('/projects/$id', projectData);
    final project = ProjectModel.fromJson(data);

    // Refresh projects list
    await getProjects();

    return project;
  }

  static Future<void> deleteProject(String id) async {
    await ApiService.delete('/projects/$id');

    // Refresh projects list
    await getProjects();
  }
}
