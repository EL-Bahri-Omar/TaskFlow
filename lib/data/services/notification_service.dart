import 'package:flutter_app/data/models/notification_model.dart';
import 'package:flutter_app/data/services/api_service.dart';
import 'package:flutter_app/data/notifiers.dart';

class NotificationService {
  static Future<List<NotificationModel>> getNotifications() async {
    final data = await ApiService.get('/notifications');
    final notifications = (data as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
    notificationsNotifier.value = notifications;
    return notifications;
  }

  static Future<int> getUnreadCount() async {
    final data = await ApiService.get('/notifications/unread-count');
    final count = data['count'] as int;
    unreadNotificationCountNotifier.value = count;
    return count;
  }

  static Future<void> markAsRead(String id) async {
    await ApiService.put('/notifications/$id/read', {});
    await getNotifications();
    await getUnreadCount();
  }

  static Future<void> markAllAsRead() async {
    await ApiService.put('/notifications/read-all', {});
    await getNotifications();
    await getUnreadCount();
  }
}
