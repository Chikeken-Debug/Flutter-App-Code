import 'dart:async';

import 'package:bird_system/cubit/app_cubit.dart';
import 'package:firebase_database/firebase_database.dart';

class DataBaseDataRepository {
  final DatabaseReference _dataBase = FirebaseDatabase.instance.ref();
  StreamSubscription? _listener;

  String get _id => AppCubit.uId;

  Future<void> buildListener(Function(String key, dynamic value) onData) async {
    await cancelListener();
    _listener =
        _dataBase.child(_id).child("lastCard").onChildChanged.listen((event) {
      onData(event.snapshot.key!, event.snapshot.value);
    });
  }

  Future<void> cancelListener() async {
    if (_listener != null) await _listener?.cancel();
  }

  void addNewUserData(
    int usersCount,
  ) {
    Map<String, dynamic> jsonData = firebaseInitialData(
        _id.split('_')[0] + '_' + '$usersCount', usersCount);
    _dataBase.child(_id.split('_')[0] + '_$usersCount').set(jsonData);
  }

  Map<String, dynamic> firebaseInitialData(String newId, int userCount) {
    return {
      "CodeVersion": "1.0.2.1",
      "controls": {},
      "states": {},
      "Temp": {"temp1": 0},
      "Hum": {"hum1": 0},
      "RFID": {"data": ",", "lastID": "NULL,notfound"},
      "Time": {"Hour": "", "Minute": "", "Seconds": ""},
      "airQuality": 0,
      "configFlag": "FF",
      "keepAlive": 0,
      "newConfig": {"pass": 123456789, "ssid": "menam", "uId": newId},
      "resetFlag": "ON",
      "usersCount": userCount,
      "valueRanges": {
        "delay": "0",
        "temp": "22,35",
        "timeToWait": "30",
        "vent": "350,400"
      }
    };
  }
}
