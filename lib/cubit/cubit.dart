import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bird_system/Layout/login_page.dart';
import 'package:bird_system/Layout/main_screen.dart';
import 'package:bird_system/Layout/rfid/user_screen.dart';
import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitial());

  static AppCubit get(context) => BlocProvider.of(context);

  final dataBase =
      FirebaseDatabase.instance.reference(); // real time firebase object
  // ignore: prefer_typing_uninitialized_variables
  var listener;

  // variables area
  String uId = ""; // user uid from firebase auth

  // additional variables
  bool hidePassword = false; //
  bool rememberMe = false;
  bool sendNewUser = false;
  bool mainDrawerValuesListBool = false;
  bool mainDrawerFarmsListBool = false;
  int currentPage = 0;
  bool networkConnection = true;
  // ignore: prefer_typing_uninitialized_variables
  bool timerListener = false;
  // devices variables
  List<bool> devicesBoolList = [true, true, true];
  List<bool> devicesLoadBoolList = [false, false, false];
  List<bool> devicesAutoBoolList = [true, true, true];
  List<bool> ledLoadSetState = [false, false];
  List<bool> ledGetState = [true, true];
  String espTime = "";
  bool isEspConnected = false;
  List<double> tempReading = [];
  List<double> humReading = [];
  double airQuality = 0;
  String airQualityText = "---";
  var maxTempController = TextEditingController();
  var minTempController = TextEditingController();
  var maxVentController = TextEditingController();
  var minVentController = TextEditingController();
  var delayController = TextEditingController();
  var historicalDelayController = TextEditingController();
  int usersCount = 0;
  int lastKeepAliveValue = 0;
  String allGraphData = "";
  List<List> allGraphDataList = [];

  // id cards data
  List<String> employeesNamesList = [];
  bool thereEmployee = true;
  int activeUser = -1;
  Map userData = {};
  String currentUserImageUrl = '';
  String currentUserId = "";
  String currentUserState = "";
  String currentUserName = "";

  // Graph List
  int numberOfGraphedData = 0;
  int realNumberOfGraphedData = -1;
  List<double> airQualityList = [];
  List<double> tempAvg = [];
  List<double> humAvg = [];
  List<List> tempGraph = [];
  List<List> humGraph = [];

  void editEmployee(Map data, BuildContext context) {
    activeUser = -1;

    emit(SendToEditLoading());
    var url = Uri.parse(
        'https://script.google.com/macros/s/AKfycbxjeykhu5BpiraSKXN_ugb-oz6_3nSC51_Oc_-zMcNywjLttXFMXJ-S0Qb3en6Y7hRS/exec?uid=$uId&fun=add&cardid=${data['ID']}&persondata=$data&index=2');
    http.read(url).then((value) {
      if (currentUserState == "notfound") {
        currentUserState = "new";
        currentUserName = data['Name'];
        dataBase.child(uId).child('RFID').update({
          "lastID": "$currentUserId,new",
          "data": "${data['Name']},${data['ImageLink']}"
        });
      }
      currentPage = 0;
      employeesNamesList = [];
      thereEmployee = true;
      Navigator.of(context)
        ..pop()
        ..pop();
      emit(SendToEditDone());
    }).catchError((err) {
      emit(SendToEditError());
      errorToast('An error happened');
    });
  }

  void deleteEmployee(int userIndex, BuildContext context) {
    emit(DeleteEmployeeLoading());
    employeesNamesList.removeAt(userIndex - 1);
    activeUser = 0;
    var url = Uri.parse(
        'https://script.google.com/macros/s/AKfycbxjeykhu5BpiraSKXN_ugb-oz6_3nSC51_Oc_-zMcNywjLttXFMXJ-S0Qb3en6Y7hRS/exec?uid=$uId&fun=delete&cardid=18010102&persondata=zzzz&index=$userIndex');
    http.read(url).then((value) {
      Navigator.of(context).pop();
      emit(DeleteEmployeeDone());
    });
  }

  void getEmployeeData(int index, BuildContext context, {bool edit = false}) {
    emit(GetPersonLoading());

    if (index == activeUser && userData.isNotEmpty) {
      emit(GetPersonDone());
      if (!edit) {
        navigateAndPush(context, UserScreen(index));
        emit(GetPersonDone());
      }
    } else {
      activeUser = index;
      var url = Uri.parse(
          'https://script.google.com/macros/s/AKfycbxjeykhu5BpiraSKXN_ugb-oz6_3nSC51_Oc_-zMcNywjLttXFMXJ-S0Qb3en6Y7hRS/exec?uid=$uId&fun=getdata&cardid=18010102&persondata=zzzz&index=$index');
      http.read(url).then((value) {
        value = '{"' + value + '"}';
        value = value.replaceAll(':,', ':NULL,');
        value = value.replaceAll(':', '":"');
        value = value.replaceAll(',', '","');
        userData = json.decode(value);
        if (!edit) {
          navigateAndPush(context, UserScreen(index));
        }
        emit(GetPersonDone());
      }).catchError((err) {
        emit(GetPersonError());
      });
    }
  }

  void getEmployeeNames() {
    emit(GetEmployeeNamesLoading());
    var url = Uri.parse(
        'https://script.google.com/macros/s/AKfycbxjeykhu5BpiraSKXN_ugb-oz6_3nSC51_Oc_-zMcNywjLttXFMXJ-S0Qb3en6Y7hRS/exec?uid=$uId&fun=getnames&cardid=18010102&persondata=zzzz&index=2');
    http.read(url).catchError((err) {
      errorToast("An error happen");
      emit(GetEmployeeNamesError());
    }).then((value) {
      employeesNamesList = [];
      if (value.startsWith('[[')) {
        value = value.replaceAll('[["', '');
        value = value.replaceAll('"]]', '');
        employeesNamesList = value.split('"],["');
      }
      if (employeesNamesList.isEmpty) {
        thereEmployee = false;
      }
      emit(GetEmployeeNamesDone());
    });
  }

  Future<void> valuesToDefault() async {
    listener.cancel();
    listener = null;
    espTime = "";
    //uId = "";
    thereEmployee = true;
    employeesNamesList = [];
    mainDrawerValuesListBool = false;
    mainDrawerFarmsListBool = false;
    currentPage = 0;
    isEspConnected = false;
    timerListener = false;
    allGraphData = "";
    allGraphDataList = [];
    activeUser = -1;
    userData = {};
    numberOfGraphedData = 0;
    realNumberOfGraphedData = -1;
  }

  void deleteDataSheet() {
    emit(DeleteSheetLoading());

    var url = Uri.parse(
        "https://script.google.com/macros/s/AKfycbwnPWp-hpkaF7RCMeWMBkYPxvx4_9z6Wlqz5soTzwsNukFcP3Qm6CWkUOBWDLOUderXjw/exec?datalength=0&uid=$uId&alldatabool=2");
    http.read(url).then((value) {
      realNumberOfGraphedData = 0;
      allGraphDataList = [
        [
          "Date",
        ]
      ];
      emit(DeleteSheetDone());
    }).catchError((err) {
      emit(DeleteSheetError());
    });
  }

  Future<void> readDataForGraph(int length) async {
    emit(GetAllGraphDataLoading());
    var url = Uri.parse(
        'https://script.google.com/macros/s/AKfycbwnPWp-hpkaF7RCMeWMBkYPxvx4_9z6Wlqz5soTzwsNukFcP3Qm6CWkUOBWDLOUderXjw/exec?datalength=$length&uid=$uId&alldatabool=0');
    http.read(url).then((value) {
      if (value.contains("has not a previous Data")) {
        emit(GetAllGraphDataDone());
        numberOfGraphedData = -1;
        return;
      }
      realNumberOfGraphedData =
          int.parse(value.split('] [[')[0].split('=[')[1]);
      if (realNumberOfGraphedData < length) {
        numberOfGraphedData = realNumberOfGraphedData;
      } else {
        numberOfGraphedData = length;
      }
      value = value.split('] [[')[1];
      value = value.replaceAll('],[', '\n');
      value = value.replaceAll(']]', '');
      List<List> data = CsvToListConverter(eol: '\n').convert(value);
      tempGraph = [];
      humGraph = [];
      for (List list in data) {
        if (list[0] == 'HUMAVG') {
          list.removeAt(0);
          humAvg = objectsToList(list, 100);
        } else if (list[0] == 'TempAVG') {
          list.removeAt(0);
          int ratio = 2 * int.parse(maxTempController.text) -
              int.parse(minTempController.text);
          tempAvg = objectsToList(list, ratio);
        } else if (list[0] == 'AirQuality') {
          list.removeAt(0);
          airQualityList = objectsToList(list, 600);
        } else if (list[0].toString().contains('hum')) {
          list.removeAt(0);
          humGraph.add(list);
        } else if (list[0].toString().contains('temp')) {
          list.removeAt(0);
          tempGraph.add(list);
        }
      }
      emit(GetAllGraphDataDone());
      return;
    }).catchError((e) {
      errorToast("Error happened Please Try again");
    });
  }

  Future<void> getAllSensorsData() async {
    emit(GetAllGraphDataLoading());
    var url = Uri.parse(
        'https://script.google.com/macros/s/AKfycbwnPWp-hpkaF7RCMeWMBkYPxvx4_9z6Wlqz5soTzwsNukFcP3Qm6CWkUOBWDLOUderXjw/exec?datalength=10&uid=$uId&alldatabool=1');
    http.read(url).catchError((e) {
      errorToast("Error happened Please Try again");
    }).then((value) {
      if (value.contains("has not a previous Data")) {
        infoToast("no data yet");
        return;
      }
      int numberOfRows = int.parse(value.split('] [[')[0].split('=[')[1]);
      value = value.split('[[')[1];
      value = value.replaceAll('],[', '\n');
      value = value.replaceAll(']]', '');
      allGraphData = value;
      allGraphDataList = CsvToListConverter(eol: '\n').convert(allGraphData);
      if (numberOfRows > 60) {
        List title = allGraphDataList[0];
        allGraphDataList =
            allGraphDataList.sublist(numberOfRows - 60, numberOfRows + 1);
        allGraphDataList.add(title);
      } else {
        allGraphDataList.add(allGraphDataList[0]);
        allGraphDataList.removeAt(0);
      }

      emit(GetAllGraphDataDone());
      return;
    });
  }

  void toCsv() async {
    emit(CsvPrepare());
    if (await Permission.storage.request().isGranted) {
      Directory? dir = await getExternalStorageDirectory();
      String newPath = "";
      List<String> folders = dir!.path.split("/");
      for (int x = 1; x < folders.length; x++) {
        if (folders[x] != 'Android') {
          newPath += "/" + folders[x];
        } else {
          break;
        }
      }
      newPath = newPath + "/Chicken Debug";
      dir = Directory(newPath);
      if (await dir.exists()) {
        File saveFile = File(dir.path + '/Data.csv');
        saveFile.writeAsString(allGraphData);
        infoToast("file saved successfully");
        emit(CsvPrepared());
      } else {
        Directory(newPath).create().then((value) {
          File saveFile = File(value.path + '/Data.csv');
          saveFile.writeAsString(allGraphData);
          infoToast("file saved successfully");
          emit(CsvPrepared());
        }).catchError((err) {
          errorToast("an error Happened");
        });
      }
    } else {
      errorToast("Permission refused");
    }
  }

  void checkKeepAlive(int allState) async {
    if (allState == 1 && timerListener == false) {
      timerListener = true;
      isEspConnected = true;
      Timer.periodic(Duration(seconds: 20), (Timer t) {
        if (uId == "") {
          t.cancel();
          return;
        }
        dataBase.child(uId).once().then((value) {
          int currentKeepAlive = value.value['keepAlive'];
          isEspConnected = (currentKeepAlive != lastKeepAliveValue);
          lastKeepAliveValue = currentKeepAlive;
          emit(KeepAliveChecked());
          if (!isEspConnected) {
            timerListener = false;
            t.cancel();
          }
        });
      });
    }
  }

  String driveToImage(String driveUrl) {
    String imageUrl = '';
    if (driveUrl.contains('drive.google.com')) {
      imageUrl = "https://drive.google.com/uc?export=view&id=" +
          driveUrl.split('/')[3];
    }
    return imageUrl;
  }

  Future<void> virtualLogOutThenIn(BuildContext context, String nextId) async {
    valuesToDefault();
    uId = nextId;
    readFireDataOnce();
    readFireDataListener();
    currentPage = 0;
    Navigator.of(context).pop();
    // navigateAndReplace(context, MainScreen(null));
  }

  void logOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await FirebaseMessaging.instance
        .unsubscribeFromTopic(uId.split("_")[0])
        .catchError((err) {
      errorToast("Error at change account");
    });
    valuesToDefault();
    prefs.clear();
    navigateAndReplace(context, LoginPage());
  }

  void readFireDataOnce() {
    tempReading = [];
    humReading = [];
    emit(GetDataLoading());
    dataBase.child(uId).once().then((snap) {
      usersCount = snap.value['usersCount'];
      lastKeepAliveValue = snap.value['keepAlive'];
      tempReading = objectsToList(snap.value['Temp'].values.toList(), 1);

      humReading = objectsToList(snap.value['Hum'].values.toList(), 1);
      airQuality = snap.value['airQuality'].toDouble();
      airQualityText = airRatioToText(airQuality.round());
      Map tempEspTime = snap.value['Time'];
      espTime =
          "${tempEspTime['Hour']}:${tempEspTime['Minute']}:${tempEspTime['Seconds']}";

      List<String> deviceName = ['Get_Led1', 'Get_Light'];
      for (int i = 0; i < deviceName.length; i++) {
        ledGetState[i] = '${snap.value['Lights'][deviceName[i]]}' == '1';
      }
      deviceName = ['Get_ManualHA', 'Get_ManualHB', 'Get_ManualF'];
      for (int i = 0; i < deviceName.length; i++) {
        devicesBoolList[i] = '${snap.value['Heaters'][deviceName[i]]}' == '1';
      }
      maxTempController.text =
          '${snap.value['valueRanges']['temp'].split(',')[1]}';
      minTempController.text =
          '${snap.value['valueRanges']['temp'].split(',')[0]}';
      maxVentController.text =
          '${snap.value['valueRanges']['vent'].split(',')[1]}';
      minVentController.text =
          '${snap.value['valueRanges']['vent'].split(',')[0]}';
      delayController.text = "${snap.value['valueRanges']['delay']}";
      historicalDelayController.text =
          "${snap.value['valueRanges']['timeToWait']}";
      currentUserName = snap.value['RFID']['data'].split(',')[0];
      currentUserImageUrl =
          driveToImage(snap.value['RFID']['data'].split(',')[1]);
      currentUserId = "${snap.value['RFID']['lastID'].split(',')[0]}";
      currentUserState = "${snap.value['RFID']['lastID'].split(',')[1]}";
      emit(GetDataDone());
    }).catchError((err) {
      //print(err);
    });
  }

  void sendToEsp(BuildContext context, String wifiName, String wifiPassword) {
    emit(SendConfigLoading());
    var url = Uri.parse(
        'http://192.168.4.1/data?user=$uId&wifi=$wifiName&pass=$wifiPassword');
    http.read(url).catchError((e) {
      errorToast(
          "Error happened ,make sure you connect to ESP wifi and try again");
      emit(SendConfigError());
    }).then((value) {
      if (value.trim() != "Failed") {
        currentPage = 0;
        navigateAndReplace(context, MainScreen(null));
        emit(SendConfigDone());
      } else {
        errorToast("Error happened ,make sure Your WIFI and pass is correct ");
        emit(SendConfigError());
      }
    });
  }

  void sendConfigOnline(
    BuildContext context,
    String wifiName,
    String wifiPassword, {
    String nextId = 'null',
    String nextPass = 'null',
  }) async {
    emit(SendConfigLoading());
    if (nextId == 'null') {
      dataBase
          .child(uId)
          .child("newConfig")
          .update({'pass': wifiName, 'ssid': wifiPassword});
      dataBase.child(uId).update({'configFlag': '1'});
      infoToast('ESP Configuration set');
      currentPage = 0;
      navigateAndReplace(context, MainScreen(null));
    } else {
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: nextId, password: nextPass)
          .then((value) {
        String nextUId = value.user!.uid + '_1';
        dataBase
            .child(uId)
            .child("newConfig")
            .update({'pass': wifiName, 'ssid': wifiPassword, 'uId': nextUId});
        dataBase.child(uId).update({'configFlag': 1});
        currentPage = 0;
        navigateAndReplace(context, MainScreen(null));
        infoToast('ESP Configuration set');
        emit(SendConfigDone());
      }).catchError((err) {
        errorToast(err.toString().split(']')[1].trim());
        emit(SendConfigError());
      });
    }
  }

  void readFireDataListener() {
    listener = dataBase.child(uId).onChildChanged.listen((event) {
      switch (event.snapshot.key) {
        case 'Heaters':
          {
            List<String> deviceName = [
              'Get_ManualHA',
              'Get_ManualHB',
              'Get_ManualF'
            ];
            for (int i = 0; i < deviceName.length; i++) {
              bool temp = '${event.snapshot.value[deviceName[i]]}' == '1';
              if (devicesBoolList[i] != temp) {
                devicesBoolList[i] = temp;
                devicesLoadBoolList[i] = false;
              }
            }
            break;
          }
        case 'Hum':
          {
            humReading = objectsToList(event.snapshot.value.values.toList(), 1);
            break;
          }
        case 'Temp':
          {
            tempReading =
                objectsToList(event.snapshot.value.values.toList(), 1);
            break;
          }
        case 'Lights':
          {
            List<String> deviceName = ['Get_Led1', 'Get_Light'];
            for (int i = 0; i < deviceName.length; i++) {
              bool temp = '${event.snapshot.value[deviceName[i]]}' == '1';
              if (ledGetState[i] != temp) {
                ledGetState[i] = temp;
                ledLoadSetState[i] = false;
              }
            }
            break;
          }
        case 'Time':
          {
            Map tempEspTime = event.snapshot.value;
            espTime =
                "${tempEspTime['Hour']}:${tempEspTime['Minute']}:${tempEspTime['Seconds']}";
            break;
          }
        case "airQuality":
          {
            airQuality = event.snapshot.value.toDouble();
            airQualityText = airRatioToText(airQuality.round());
            break;
          }
        case "keepAlive":
          {
            lastKeepAliveValue = -1;
            isEspConnected = true;
            checkKeepAlive(1);
            break;
          }
        case "RFID":
          {
            currentUserName = event.snapshot.value['data'].split(',')[0];
            currentUserImageUrl =
                driveToImage(event.snapshot.value['data'].split(',')[1]);
            currentUserId = "${event.snapshot.value['lastID'].split(',')[0]}";
            currentUserState =
                "${event.snapshot.value['lastID'].split(',')[1]}";
            break;
          }
        case "valueRanges":
          {
            maxTempController.text =
                '${event.snapshot.value['temp'].split(',')[1]}';
            minTempController.text =
                '${event.snapshot.value['temp'].split(',')[0]}';
            maxVentController.text =
                '${event.snapshot.value['vent'].split(',')[1]}';
            minVentController.text =
                '${event.snapshot.value['vent'].split(',')[0]}';
            delayController.text = "${event.snapshot.value['delay']}";
            historicalDelayController.text =
                "${event.snapshot.value['timeToWait']}";
            break;
          }
      }
      emit(GetDataDone());
    });
  }

  String airRatioToText(int ratio) {
    List<String> airText = [
      'fresh',
      'Safe',
      'good',
      'medium',
      'danger',
      'danger+',
      'danger++'
    ];
    List<int> ranges = [40, 100, 150, 250, 300, 400, 500];
    for (int i = 0; i < ranges.length; i++) {
      if (ratio <= ranges[i]) {
        return airText[i];
      }
    }
    return "Died";
  }

  List<double> objectsToList(List oldList, int ratio) {
    if (ratio == -1) {
      ratio = 2 * int.parse(maxTempController.text) -
          int.parse(minTempController.text);
    }

    List<double> newList = [];
    for (var i in oldList) {
      try {
        newList.add(i.toDouble() / ratio);
      } catch (err) {
        continue;
      }
    }
    return newList;
  }

  void networkListener() {
    Connectivity().checkConnectivity().then((value) {
      networkConnection = (value != ConnectivityResult.none);
      emit(NetworkConnectionChangeState());
    });

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      networkConnection = (result != ConnectivityResult.none);
      emit(NetworkConnectionChangeState());
      if (networkConnection) {
        if (listener == null && uId != "") {
          readFireDataListener();
          readFireDataOnce();
        }
      }
    });
  }

  void addFarmDevise() {
    usersCount++;
    for (int i = 1; i < usersCount; i++) {
      dataBase
          .child(uId.split('_')[0] + '_$i')
          .update({'usersCount': usersCount});
    }
    String jsonData = firebaseInitialData(
        uId.split('_')[0] + '_' + '$usersCount', usersCount);
    var data = json.decode(jsonData);
    dataBase.child(uId.split('_')[0] + '_$usersCount').set(data);
    emit(AddFarmDeviseState());
  }

  void signIn(BuildContext context, String email, String password) async {
    /*
    * library to login "it take the email and password and return uid"
    * */

    emit(UserSignInLoading());
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      uId = value.user!.uid + '_1';
      readFireDataOnce();
      readFireDataListener();
      await FirebaseMessaging.instance.subscribeToTopic(uId.split("_")[0]);
      if (value.user!.emailVerified) {
        saveData(uId);
        currentPage = 0;
        navigateAndReplace(context, MainScreen(null));
        emit(UserSignUpDone());
      } else {
        emit(UserSignInVerifyError());

        User user = value.user!;
        user
            .sendEmailVerification()
            .whenComplete(() {
              emit(UserVerifyLoading());
            })
            .timeout(Duration(minutes: 2))
            .catchError((err) {
              emit(UserSignUpError());
              errorToast("verification error");
            });
      }
    }).catchError((err) {
      errorToast(err.toString().split(']')[1].trim());
      emit(UserSignInError());
    });
  }

  void getUserLoginData(bool? checkRemember) async {
    emit(CheckUserStateLoading());
    final prefs = await SharedPreferences.getInstance();
    if (checkRemember == true) {
      String uId = prefs.getString("uId")!;
      this.uId = uId;
      readFireDataOnce();
      readFireDataListener();
      currentPage = 0;
      emit(UserSignUpDone());
    }
    networkListener();
    emit(CheckUserStateDone());
  }

  void saveData(String uId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', rememberMe);
    if (rememberMe) {
      prefs.setString('uId', uId);
    }
  }

  void forgetPassword(BuildContext context, String email) async {
    /*
    * library to sign up "it take the email and password and return uid"
    * */
    bool errorHappen = false;
    emit(UserSignUpLoading());
    FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .catchError((err) {
      errorToast(err.toString());
      errorHappen = true;
    }).whenComplete(() {
      if (!errorHappen) {
        Navigator.of(context).pop();
        infoToast("Password reset email sent to your email");
      }
    }).timeout(Duration(minutes: 2));
  }

  String firebaseInitialData(String newId, int userCount) {
    return '''
    {
    "CodeVersion" : "1.0.2.1",
    "Heaters" : {
      "Cooler_status" : 0,
      "FanAuto" : "0",
      "Get_ManualF" : 0,
      "Get_ManualHA" : 0,
      "Get_ManualHB" : 0,
      "Set_ManualF" : "0",
      "Set_ManualHA" : "0",
      "Set_ManualHB" : "0",
      "WhichHeater" : "0",
      "heaterA_status" : 0,
      "heaterAauto" : "0",
      "heaterBAuto" : "0",
      "heaterB_status" : 0,
      "startTime" : {
        "A" : "FF",
        "B" : "FF"
      },
      "whichHeater" : "0"
    },
    "Hum" : {
    "hum1" : 0
    },
    "Lights" : {
      "Get_Led1" : 0,
      "Get_Light" : 0,
      "Set_Led1" : "0",
      "Set_Light" : "0"
    },
    "RFID" : {
      "data" : ",",
      "lastID" : "NULL,notfound"
    },
    "Temp" : {
    "hum1" : 0
    },
    "Time" : {
      "Hour" : "",
      "Minute" : "",
      "Seconds" : ""
    },
    "airQuality" : 0,
    "configFlag" : "FF",
    "keepAlive" : 0,
    "newConfig" : {
      "pass" : 123456789,
      "ssid" : "menam",
      "uId" : "$newId"
    },
    "resetFlag" : "0",
    "usersCount" : $userCount,
    "valueRanges" : {
      "delay" : "0",
      "temp" : "22,35",
      "timeToWait" : "30",
      "vent" : "350,400"
    }
}
    ''';
  }

  void signUp(BuildContext context, String email, String password) async {
    /*
    * library to sign up "it take the email and password and return uid"
    * */
    emit(UserSignUpLoading());
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((value) {
      uId = value.user!.uid + '_1';
      String jsonData = firebaseInitialData(uId, 1);

      var data = json.decode(jsonData);
      dataBase.child(uId).set(data);

      User user = value.user!;
      user
          .sendEmailVerification()
          .whenComplete(() {
            emit(UserVerifyLoading());
            infoToast("Verification email sent to our email please check it");
            Future.delayed(const Duration(seconds: 5), () {
              navigateAndReplace(context, LoginPage());
            });
          })
          .timeout(Duration(minutes: 2))
          .catchError((err) {
            emit(UserSignUpError());
            errorToast("verification error");
          });
    }).catchError((err) {
      emit(UserSignUpError());
      errorToast(err.toString().split(']')[1].trim());
    });
  }

  void deviceStatus(int device) {
    if (!devicesAutoBoolList[device]) {
      List<String> deviceName = ['Set_ManualHA', 'Set_ManualHB', 'Set_ManualF'];
      devicesLoadBoolList[device] = true;
      dataBase.child(uId).child('Heaters').update({
        deviceName[device]: !devicesBoolList[device] ? "1" : "0"
      }).then((value) {
        emit(ChangeDeviceStatus());
      }).catchError((err) {
        errorToast("an error happened");
      });
    } else {
      errorToast("device is Automatic");
    }
  }

  void deviceAutoStatus(int index) {
    List<String> deviceName = ['heaterAauto', 'heaterBAuto', 'FanAuto'];

    devicesAutoBoolList[index] = !devicesAutoBoolList[index];
    dataBase.child(uId).child('Heaters').update({
      deviceName[index]: devicesAutoBoolList[index] ? "1" : "0"
    }).then((value) {
      emit(ChangeDeviceStatus());
    }).catchError((err) {
      errorToast("an error happened");
    });
  }

  void ledStatus(int index) {
    List<String> deviceName = ['Set_Led1', 'Set_Light'];

    ledLoadSetState[index] = true;
    dataBase.child(uId).child('Lights').update(
        {deviceName[index]: !ledGetState[index] ? '1' : '0'}).then((value) {
      emit(ChangeDeviceStatus());
    }).catchError((err) {
      errorToast("an error happened");
    });
    emit(ChangeDeviceStatus());
  }

  void sendValuesRanges() {
    dataBase.child(uId).child("valueRanges").update({
      "delay": delayController.text,
      "temp": "${minTempController.text},${maxTempController.text}",
      "vent": "${minVentController.text},${maxVentController.text}",
      "timeToWait": historicalDelayController.text
    }).then((value) {
      emit(SendDataToFireState());
    }).catchError((err) {
      errorToast("An error Happened");
    });
  }

  void sendResetEsp() {
    dataBase.child(uId).update({'resetFlag': "1"}).then((value) {
      infoToast('ESP reset successfully');
      emit(SendDataToFireState());
    }).catchError((err) {
      errorToast("An error Happened");
    });
  }

  void changePassShowClicked() {
    hidePassword = !hidePassword;
    emit(ChangePassShowState());
  }

  void changeCurrentScreen(int screen) {
    currentPage = screen;
    emit(AppChangeScreen());
  }

  void rememberMeBoxClicked() {
    rememberMe = !rememberMe;
    emit(ChangeRememberBoxShowState());
  }

  void sendNewUserCheckBox() {
    sendNewUser = !sendNewUser;
    emit(ChangeRememberBoxShowState());
  }

  void mainDrawerValuesList() {
    mainDrawerValuesListBool = !mainDrawerValuesListBool;
    emit(MainDrawerValuesListState());
  }

  void mainDrawerFarmsListList() {
    mainDrawerFarmsListBool = !mainDrawerFarmsListBool;
    emit(MainDrawerValuesListState());
  }
}
