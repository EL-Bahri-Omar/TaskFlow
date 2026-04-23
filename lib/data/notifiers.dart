//ValueNotifier: hold the data
//ValueListenableBuilder: listen to the data (dont need the setstate)

import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/data/models/task_model.dart';
import 'package:flutter_app/data/models/project_model.dart';
import 'package:flutter_app/data/models/notification_model.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);
ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(true);

// Auth state
ValueNotifier<String?> authTokenNotifier = ValueNotifier(null);
ValueNotifier<UserModel?> currentUserNotifier = ValueNotifier(null);

// Data state
ValueNotifier<List<TaskModel>> tasksNotifier = ValueNotifier([]);
ValueNotifier<List<ProjectModel>> projectsNotifier = ValueNotifier([]);
ValueNotifier<List<UserModel>> allUsersNotifier = ValueNotifier([]);

// Notifications
ValueNotifier<List<NotificationModel>> notificationsNotifier = ValueNotifier([]);
ValueNotifier<int> unreadNotificationCountNotifier = ValueNotifier(0);

// Stats
ValueNotifier<Map<String, int>> taskStatsNotifier = ValueNotifier({
  'total': 0,
  'todo': 0,
  'inProgress': 0,
  'done': 0,
});

// Settings
ValueNotifier<bool> notificationsEnabledNotifier = ValueNotifier(true);
