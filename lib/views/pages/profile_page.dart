import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/views/pages/login_page.dart';
import 'package:flutter_app/views/pages/update_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: ValueListenableBuilder(
        valueListenable: currentUserNotifier,
        builder: (context, user, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50.0,
                  backgroundColor: Colors.teal,
                  backgroundImage: user?.avatar != null && user!.avatar.length > 100
                      ? MemoryImage(base64Decode(user.avatar))
                      : null,
                  child: user?.avatar == null || user!.avatar.length <= 100
                      ? Text(
                          (user?.name ?? 'U')[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                SizedBox(height: 16),
                Text(
                  user?.name ?? 'User',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 16),

                // Update profile button
                OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UpdateProfilePage()),
                    );
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Update Profile'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(200, 40),
                  ),
                ),
                SizedBox(height: 24),

                // My Projects - clickable
                ValueListenableBuilder(
                  valueListenable: projectsNotifier,
                  builder: (context, projects, child) {
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.folder, color: Colors.teal),
                        title: Text("My Projects"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${projects.length}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                        onTap: () {
                          // Navigate to Projects tab
                          selectedPageNotifier.value = 2;
                        },
                      ),
                    );
                  },
                ),
                SizedBox(height: 8),

                // My Activity - clickable
                ValueListenableBuilder(
                  valueListenable: taskStatsNotifier,
                  builder: (context, stats, child) {
                    return Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.assignment, color: Colors.teal),
                            title: Text("My Tasks"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${stats['total'] ?? 0}",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.chevron_right, color: Colors.grey),
                              ],
                            ),
                            onTap: () {
                              // Navigate to Tasks tab
                              selectedPageNotifier.value = 1;
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(height: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _statItem(Icons.check_circle, '${stats['done'] ?? 0}', 'Done', Colors.green),
                                _statItem(Icons.timelapse, '${stats['inProgress'] ?? 0}', 'Progress', Colors.orange),
                                _statItem(Icons.radio_button_unchecked, '${stats['todo'] ?? 0}', 'To Do', Colors.grey),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),

                // Logout
                Card(
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Logout', style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Logout'),
                          content: Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: FilledButton.styleFrom(backgroundColor: Colors.red),
                              child: Text('Logout'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        // Navigate FIRST, then clear data
                        // This prevents WidgetTree from rebuilding with empty state
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => LoginPage(title: 'Login')),
                          (route) => false,
                        );
                        await AuthService.logout();
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
