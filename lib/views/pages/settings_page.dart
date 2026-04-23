import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    _loadNotificationPref();
  }

  void _loadNotificationPref() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notificationsEnabled') ?? true;
    notificationsEnabledNotifier.value = enabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section
              Text("Appearance", style: KTextStyle.titleTealText),
              SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: isDarkModeNotifier,
                      builder: (context, isDarkMode, child) {
                        return SwitchListTile.adaptive(
                          title: Text("Dark Mode"),
                          subtitle: Text("Toggle dark/light theme"),
                          secondary: Icon(
                            isDarkMode ? Icons.dark_mode : Icons.light_mode,
                            color: Colors.teal,
                          ),
                          value: isDarkMode,
                          onChanged: (bool value) async {
                            isDarkModeNotifier.value = value;
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setBool(KConstants.themeModeKey, value);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Notifications Section
              Text("Notifications", style: KTextStyle.titleTealText),
              SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: notificationsEnabledNotifier,
                      builder: (context, enabled, child) {
                        return SwitchListTile.adaptive(
                          title: Text("Push Notifications"),
                          subtitle: Text(
                            enabled
                                ? "Notifications are enabled"
                                : "Notifications are disabled",
                          ),
                          secondary: Icon(
                            enabled
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            color: enabled ? Colors.teal : Colors.grey,
                          ),
                          value: enabled,
                          onChanged: (bool value) async {
                            notificationsEnabledNotifier.value = value;
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('notificationsEnabled', value);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
