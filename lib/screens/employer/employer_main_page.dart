import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_guild_for_jobseekers_v3/screens/employer/employer_jobs_page.dart';
import 'package:mobile_guild_for_jobseekers_v3/screens/employer/employer_homescreen_page.dart';
import 'package:mobile_guild_for_jobseekers_v3/screens/employer/employer_notification_page.dart';
import 'package:mobile_guild_for_jobseekers_v3/screens/employer/employer_setting_page.dart';

// ignore: unused_import
import '../../Auth/usertype.dart';

class EmployerMainPage extends StatefulWidget {
  const EmployerMainPage({super.key});

  @override
  State<EmployerMainPage> createState() => _EmployerMainPageMainPageState();
}

class _EmployerMainPageMainPageState extends State<EmployerMainPage> {
  int index = 0;
  final screens = [
    const EmployerHomeScreenPage(),
    const EmployerNotificationPage(),
    const EmployerJobPage(),
    const EmployerSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.blue.shade100,
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        child: NavigationBar(
          elevation: 10,
          height: 60,
          backgroundColor: Colors.blueGrey,
          selectedIndex: index,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          animationDuration: const Duration(seconds: 1),
          onDestinationSelected: (index) {
            setState(() {
              this.index = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_filled),
              label: "Home",
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications_active),
              label: "Notification",
            ),
            NavigationDestination(
              icon: Icon(Icons.work_outline),
              selectedIcon: Icon(Icons.work),
              label: "Jobs",
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}
