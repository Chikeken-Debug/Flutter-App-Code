import 'dart:convert';
import 'package:bird_system/Layout/main_screen.dart';
import 'package:bird_system/cubit/cubit.dart';
import 'package:bird_system/cubit/states.dart';
import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class NotificationPage extends StatelessWidget {
  NotificationPage(this.notificationData, this.fromMain, {Key? key})
      : super(key: key) {
    if (notificationData is String) {
      print(notificationData);
      try {
        data = json.decode(notificationData);
      } catch (err) {
        print(err);
      }
    } else {
      data = notificationData;
    }
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove("notificationInfo");
    });
  }

  // ignore: prefer_typing_uninitialized_variables
  var notificationData;
  bool fromMain;
  late Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (BuildContext context, AppStates state) {},
      builder: (BuildContext context, AppStates state) {
        // AppCubit cubit = AppCubit.get(context);

        return WillPopScope(
          onWillPop: () async {
            if (fromMain) {
              navigateAndReplace(context, MainScreen());
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () {
                    if (fromMain) {
                      navigateAndReplace(context, MainScreen());
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                title: Text(data['Title'] ?? "Notification"),
              ),
              body: Text(data['Body'] ?? "see the dashboard")),
        );
      },
    );
  }
}
