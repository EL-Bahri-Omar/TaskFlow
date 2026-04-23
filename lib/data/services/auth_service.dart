import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/data/services/api_service.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<UserModel> register(String name, String email, String password) async {
    final data = await ApiService.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });

    final user = UserModel.fromJson(data);

    if (user.token != null) {
      authTokenNotifier.value = user.token;
      currentUserNotifier.value = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(KConstants.authTokenKey, user.token!);
      await prefs.setString(KConstants.userIdKey, user.id);
    }

    return user;
  }

  static Future<UserModel> login(String email, String password) async {
    final data = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final user = UserModel.fromJson(data);

    if (user.token != null) {
      authTokenNotifier.value = user.token;
      currentUserNotifier.value = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(KConstants.authTokenKey, user.token!);
      await prefs.setString(KConstants.userIdKey, user.id);
    }

    return user;
  }

  static Future<UserModel> getMe() async {
    final data = await ApiService.get('/auth/me');
    final user = UserModel.fromJson(data);
    currentUserNotifier.value = user;
    return user;
  }

  static Future<UserModel> updateProfile(Map<String, dynamic> profileData) async {
    final data = await ApiService.put('/auth/profile', profileData);
    final user = UserModel.fromJson(data);
    currentUserNotifier.value = user;
    return user;
  }

  static Future<List<UserModel>> getUsers() async {
    final data = await ApiService.get('/auth/users');
    final users = (data as List).map((json) => UserModel.fromJson(json)).toList();
    allUsersNotifier.value = users;
    return users;
  }

  static Future<void> logout() async {
    authTokenNotifier.value = null;
    currentUserNotifier.value = null;
    tasksNotifier.value = [];
    projectsNotifier.value = [];
    allUsersNotifier.value = [];
    notificationsNotifier.value = [];
    unreadNotificationCountNotifier.value = 0;
    taskStatsNotifier.value = {'total': 0, 'todo': 0, 'inProgress': 0, 'done': 0};
    selectedPageNotifier.value = 0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KConstants.authTokenKey);
    await prefs.remove(KConstants.userIdKey);
  }

  static Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(KConstants.authTokenKey);

    if (token != null) {
      authTokenNotifier.value = token;
      try {
        await getMe();
        return true;
      } catch (e) {
        await logout();
        return false;
      }
    }
    return false;
  }
}
