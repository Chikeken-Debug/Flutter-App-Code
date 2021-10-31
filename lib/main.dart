import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Layout/login_page.dart';
import 'cubit/bloc_observer.dart';
import 'cubit/cubit.dart';

void main() {
  Bloc.observer = MyBlocObserver();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: customGreen, // status bar color
  ));

  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit(),
      child: MaterialApp(
        title: 'Bird APP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightGreen,
        ),
        home: LoginPage(),
      ),
    );
  }
}
