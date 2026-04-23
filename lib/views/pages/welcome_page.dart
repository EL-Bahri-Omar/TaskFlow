import 'package:flutter/material.dart';
import 'package:flutter_app/views/pages/login_page.dart';
import 'package:flutter_app/views/pages/register_page.dart';
import 'package:lottie/lottie.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/lotties/dataman.json', height: 200.0),
                Text(
                  "TaskFlow",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 42.0,
                    letterSpacing: 5.0,
                  ),
                ),
                SizedBox(height: 6.0),
                Text(
                  "Intelligent Task Management",
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.teal,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Organize your tasks, collaborate with your team, and track progress — all in one place.',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '• Create and manage tasks\n• Organize by projects\n• Assign tasks to team members\n• Track progress in real-time',
                    style: TextStyle(fontSize: 13.0, color: Colors.teal),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: 20.0),
                FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return RegisterPage();
                        },
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: Size(double.infinity, 40.0),
                  ),
                  child: Text('Get Started'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return LoginPage(title: 'Login');
                        },
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: Size(double.infinity, 40.0),
                  ),
                  child: Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
