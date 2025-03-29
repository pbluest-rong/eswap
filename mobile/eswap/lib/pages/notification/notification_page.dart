import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  static const String route = '/notification';

  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage?;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("notification".tr(),
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
          child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildNotificationItem(message),
              SizedBox(height: 10,),
              _buildNotificationItem(message),
              SizedBox(height: 10,),
              _buildNotificationItem(message),
            ],
          ),
        ),
      )),
    );
  }
  Widget _buildNotificationItem(message){
    return Container(
      color: Colors.yellow,
      alignment: AlignmentDirectional.centerStart,
      width: double.infinity,
      child: Column(
        children: [
          Text('Title: ${message?.notification?.title ?? "No title"}'),
          Text('Body: ${message?.notification?.body ?? "No body"}'),
          Text('Data: ${message?.data ?? "No data"}'),
        ],
      ),
    );
  }
}
