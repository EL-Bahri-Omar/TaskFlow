import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class KConstants {
  static const String themeModeKey = 'themeModeKey';
  static const String authTokenKey = 'authTokenKey';
  static const String userIdKey = 'userIdKey';
}

class KTextStyle {
  static const TextStyle titleTealText = TextStyle(
    color: Colors.teal,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle descriptionText = TextStyle(fontSize: 16.0);
}

class KApi {
  // For physical Android device, use your computer's WiFi IP
  // For Android emulator, use 10.0.2.2
  // For web/desktop, use localhost
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    if (Platform.isAndroid) {
      // Use your computer's WiFi IP for physical device
      return 'http://192.168.100.20:3000/api';
    }
    return 'http://localhost:3000/api';
  }
}

class KTaskStatus {
  static const String todo = 'todo';
  static const String inProgress = 'inProgress';
  static const String done = 'done';

  static const List<String> all = [todo, inProgress, done];

  static String label(String status) {
    switch (status) {
      case todo:
        return 'To Do';
      case inProgress:
        return 'In Progress';
      case done:
        return 'Done';
      default:
        return status;
    }
  }

  static Color color(String status) {
    switch (status) {
      case todo:
        return Colors.grey;
      case inProgress:
        return Colors.orange;
      case done:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  static IconData icon(String status) {
    switch (status) {
      case todo:
        return Icons.radio_button_unchecked;
      case inProgress:
        return Icons.timelapse;
      case done:
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
}

class KPriority {
  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';

  static const List<String> all = [low, medium, high];

  static String label(String priority) {
    switch (priority) {
      case low:
        return 'Low';
      case medium:
        return 'Medium';
      case high:
        return 'High';
      default:
        return priority;
    }
  }

  static Color color(String priority) {
    switch (priority) {
      case low:
        return Colors.green;
      case medium:
        return Colors.orange;
      case high:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData icon(String priority) {
    switch (priority) {
      case low:
        return Icons.arrow_downward;
      case medium:
        return Icons.remove;
      case high:
        return Icons.arrow_upward;
      default:
        return Icons.help;
    }
  }
}
