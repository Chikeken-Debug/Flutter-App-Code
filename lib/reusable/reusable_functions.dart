import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Color customGreen = Colors.lightGreen;

Color customViolet = Color.fromRGBO(201, 137, 239, 1.0);
Color customGrey = Color.fromRGBO(64, 64, 64, 1.0);

void navigateAndReplace(BuildContext context, Widget newScreen) {
  Navigator.pushAndRemoveUntil<dynamic>(
    context,
    MaterialPageRoute<dynamic>(
      builder: (BuildContext context) => newScreen,
    ),
    (route) => false, //if you want to disable back feature set to false
  );
}

void customCupertinoDialog(
  BuildContext context, {
  required String title,
  required String content,
  required Function yesFunction,
}) {
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              OutlinedButton(
                  //  isDefaultAction: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "no",
                    style: TextStyle(color: Colors.green),
                  )),
              OutlinedButton(
                  //isDefaultAction: true,
                  onPressed: () async {
                    yesFunction();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Yes",
                    style: TextStyle(color: Colors.red),
                  )),
            ],
          ));
}

void navigateAndPush(BuildContext context, Widget newScreen) {
  Navigator.push(context, MaterialPageRoute(
    builder: (context) {
      return newScreen;
    },
  ));
}

void errorToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

void infoToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0);
}
