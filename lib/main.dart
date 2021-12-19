import 'package:bird_system/reusable/fire_message.dart';
import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Layout/login_page.dart';
import 'Layout/main_screen.dart';
import 'cubit/cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Bloc.observer = MyBlocObserver();

  if (await Permission.notification.request().isGranted) {
    FireNotificationHelper();
  }

  final prefs = await SharedPreferences.getInstance();
  bool? rememberMe = prefs.getBool("rememberMe");

  String? notificationData = prefs.getString("notificationInfo");
  print("notificationData");
  print(notificationData);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: customGreen, // status bar color
  ));

  runApp(MyApp(rememberMe, notificationData));
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  bool? rememberMe;
  String? notificationData;
  MyApp(this.rememberMe, this.notificationData, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          AppCubit()..getUserLoginData(rememberMe),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Bird APP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightGreen,
        ),
        home: rememberMe ?? false ? MainScreen(notificationData) : LoginPage(),
      ),
    );
  }
}
