import 'package:flutter/material.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/data/services/notification_service.dart';
import 'package:flutter_app/data/services/task_service.dart';
import 'package:flutter_app/views/pages/task_view_page.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      await NotificationService.getNotifications();
      await NotificationService.getUnreadCount();
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _navigateToTask(String? taskId) async {
    if (taskId == null) return;

    try {
      final task = await TaskService.getTask(taskId);
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskViewPage(task: task),
          ),
        );
        // Refresh after coming back
        _loadNotifications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task not found or has been deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await NotificationService.markAllAsRead();
              if (mounted) setState(() {});
            },
            child: Text('Mark all read'),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ValueListenableBuilder(
                valueListenable: notificationsNotifier,
                builder: (context, notifications, child) {
                  if (notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No notifications',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      final taskId = notif.task?['_id'] as String?;

                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        color: notif.read
                            ? null
                            : Colors.teal.withValues(alpha: 0.1),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                notif.read ? Colors.grey : Colors.teal,
                            child: Icon(
                              notif.read
                                  ? Icons.notifications_none
                                  : Icons.notifications_active,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            notif.message,
                            style: TextStyle(
                              fontWeight: notif.read
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('dd MMM yyyy, HH:mm')
                                .format(notif.createdAt),
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: taskId != null
                              ? Icon(Icons.chevron_right, color: Colors.grey)
                              : null,
                          onTap: () async {
                            // Mark as read
                            if (!notif.read) {
                              await NotificationService.markAsRead(notif.id);
                            }
                            // Navigate to task
                            _navigateToTask(taskId);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
