import 'dart:async';
import 'dart:convert';
import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:shared_preferences/shared_preferences.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FireNotificationHelper {
  String? token;
  FireNotificationHelper() {
    getToken();
    // app opened now
    FirebaseMessaging.onMessage
        .listen(_firebaseMessagingForegroundHandler)
        .onError((err) {});

    // app on back ground
    FirebaseMessaging.onMessageOpenedApp
        .listen(_firebaseMessagingBackgroundHandler)
        .onError((err) {});

    FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundCloseHandler);
  }

  Future<void> _firebaseMessagingForegroundHandler(
      RemoteMessage message) async {
    redirectPage(message.data);
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    redirectPage(message.data);
  }

  Future<void> redirectPage(Map<String, dynamic> data) async {
    Vibrate.feedback(FeedbackType.heavy);
    infoToast("Notification come");
    showDialog(
      context: navigatorKey.currentState!.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(data['Title'] ?? "something unmoral happened"),
          content: Text(data['Body'] ?? "Check The dashboard"),
          actions: [
            OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Ok")),
          ],
        );
      },
    );
  }

  void getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    // print("token : " + token!);
  }
}

Future<void> _firebaseMessagingBackgroundCloseHandler(
    RemoteMessage message) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("notificationInfo", json.encode(message.data));
}
