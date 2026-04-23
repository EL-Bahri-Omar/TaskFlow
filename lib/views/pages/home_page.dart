import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/data/services/task_service.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/data/services/notification_service.dart';
import 'package:flutter_app/views/widgets/hero_widget.dart';
import 'package:flutter_app/views/widgets/stats_widget.dart';
import 'package:flutter_app/views/widgets/task_card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await TaskService.getStats();
      await TaskService.getTasks();
      await AuthService.getUsers();
      await NotificationService.getUnreadCount();
    } catch (e) {
      // Handle error silently
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.0),
              ValueListenableBuilder(
                valueListenable: currentUserNotifier,
                builder: (context, user, child) {
                  return Text(
                    "Welcome, ${user?.name ?? 'User'}",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              SizedBox(height: 5.0),
              Text(
                "Here's your task overview",
                style: TextStyle(fontSize: 14.0, color: Colors.grey),
              ),
              SizedBox(height: 15.0),
              HeroWidget(title: "TaskFlow"),
              SizedBox(height: 20.0),

              // Stats — tasks assigned to the connected member
              Text("My Statistics", style: KTextStyle.titleTealText),
              SizedBox(height: 10.0),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ValueListenableBuilder(
                      valueListenable: taskStatsNotifier,
                      builder: (context, stats, child) {
                        return GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.8,
                          children: [
                            StatsWidget(
                              title: "Total",
                              count: stats['total'] ?? 0,
                              icon: Icons.assignment,
                              color: Colors.teal,
                            ),
                            StatsWidget(
                              title: "To Do",
                              count: stats['todo'] ?? 0,
                              icon: Icons.radio_button_unchecked,
                              color: Colors.grey,
                            ),
                            StatsWidget(
                              title: "In Progress",
                              count: stats['inProgress'] ?? 0,
                              icon: Icons.timelapse,
                              color: Colors.orange,
                            ),
                            StatsWidget(
                              title: "Done",
                              count: stats['done'] ?? 0,
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                          ],
                        );
                      },
                    ),
              SizedBox(height: 20.0),

              // Recent Tasks — tasks assigned to me or in my projects
              Text("Recent Tasks", style: KTextStyle.titleTealText),
              SizedBox(height: 10.0),
              ValueListenableBuilder(
                valueListenable: tasksNotifier,
                builder: (context, tasks, child) {
                  if (_isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (tasks.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            "No tasks yet. Create your first task!",
                            style: KTextStyle.descriptionText,
                          ),
                        ),
                      ),
                    );
                  }
                  final recentTasks = tasks.take(5).toList();
                  return Column(
                    children: recentTasks.map((task) {
                      return TaskCardWidget(task: task);
                    }).toList(),
                  );
                },
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
