import "package:flutter/material.dart";

class NotificationScreen extends StatefulWidget {
  final String name;
  final String description;
  const NotificationScreen({
    super.key,
    required this.name,
    required this.description,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Screen"),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.description,
              style: const TextStyle(
                fontSize: 24,
              ),
            )
          ],
        ),
      ),
    );
  }
}
