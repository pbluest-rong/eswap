import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class DemoNotification extends StatelessWidget {
  static const String route = '/notification';

  const DemoNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage?;
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("DEMO NOTIFICATION"),
            SizedBox(height: 20,),
            Text('Title: ${message?.notification?.title ?? "No title"}'),
            Text('Body: ${message?.notification?.body ?? "No body"}'),
            Text('Data: ${message?.data ?? "No data"}'),
          ],
        )
      ),
    );
  }
}
