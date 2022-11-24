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
      "Hum": {"H1": 0},
      "RFID": {"data": ",", "lastID": "NULL,notfound"},
      "Status":{"Clear_Reset_Reason": "OFF","ESP_RST_BROWNOUT" :0,"ESP_RST_DEEPSLEEP": 0,"ESP_RST_EXT": 0,"ESP_RST_INT_WDT": 0,"ESP_RST_PANIC": 0,"ESP_RST_POWERON": 0,"ESP_RST_SDIO": 0,"ESP_RST_SW": 0,"ESP_RST_TASK_WDT": 0,"ESP_RST_UNKNOWN": 0,"ESP_RST_WDT": 0,"Last_Reset": "","WDT_Action": "MORMAL"},
      "Temp": {"T1": 0},
      "Time": {"Hour": "", "Minute": "", "Seconds": ""},
      "airQuality": {"Q1": 1},
      "config":{"Cool_min_interval":"10","Cooler_off_time":"240","Cooler_on_time":"60","Fan_min_interval":"10","Fan_off_time":"60","Fan_on_time":"240","Gas1_Cal":"0","Gas2_Cal":"0","Heat_min_interval":"10","Heater_off_time":"60","Heater_on_time":"240","Temp_variance_Cool":"2","Temp_variance_FanA":"0","Temp_variance_FabB":"1"},
      "configFlag": "FF",
      "controls": {},
      "keepAlive": 0,
      "newConfig": {"pass": 123456789, "ssid": "menam", "uId": newId},
      "resetFlag": "ON",
      "states": {},
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
