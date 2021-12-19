import 'dart:async';
import 'dart:convert';
import 'package:bird_system/Layout/notification_screen.dart';
import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:shared_preferences/shared_preferences.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FireNotificationHelper {
  FireNotificationHelper() {
    getToken();

    print("Firebase messaging initialize");

    // app opened now
    FirebaseMessaging.onMessage
        .listen(_firebaseMessagingForegroundHandler)
        .onError((err) {
      print("err");
    });

    // app on back ground
    FirebaseMessaging.onMessageOpenedApp
        .listen(_firebaseMessagingBackgroundHandler)
        .onError((err) {
      print("err");
    });

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("notificationInfo", data.toString());
    navigateAndPush(
        navigatorKey.currentState!.context, NotificationPage(data, false));
    print(data);
  }

  void getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("token : " + token!);
  }
}

Future<void> _firebaseMessagingBackgroundCloseHandler(
    RemoteMessage message) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("notificationInfo", json.encode(message.data));
  print("on off state");
}
