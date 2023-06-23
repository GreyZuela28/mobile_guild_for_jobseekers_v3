import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Auth/signup_screen.dart';
import '../../Auth/usertype.dart';
import 'jobseeker_bookmark_page.dart';
import 'jobseeker_homescreen_page.dart';
import 'jobseeker_notification_page.dart';
import 'jobseeker_setting_page.dart';

class JobseekerMainPage extends StatefulWidget {
  const JobseekerMainPage({super.key});

  @override
  State<JobseekerMainPage> createState() => _JobseekerMainPageMainPageState();
}

class _JobseekerMainPageMainPageState extends State<JobseekerMainPage> {
  int index = 0;
  final screens = [
    const JobseekerHomeScreenPage(),
    const JobseekerNotificationPage(),
    const JobseekerBookmarkPage(),
    const JobseekerSettingsPage(),
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
              icon: Icon(Icons.bookmark_outline),
              selectedIcon: Icon(Icons.bookmark),
              label: "bookmark",
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
