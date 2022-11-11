import 'dart:async';
import 'package:bird_system/Layout/login_page.dart';
import 'package:bird_system/Layout/main_screen.dart';
import 'package:bird_system/Layout/rfid/user_screen.dart';
import 'package:bird_system/model/repository/auth_repository.dart';
import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import '../model/repository/realtime_firebase.dart';
import '../model/repository/web_sevices.dart';
import 'states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitial());

  static AppCubit get(context) => BlocProvider.of(context);
  static String uId = ""; // user uid from firebase auth

  final AuthRepository _auth = AuthRepository();
  final DataBaseDataRepository _dataRepository = DataBaseDataRepository();
  final WebServices _webServices = WebServices();

  final dataBase = FirebaseDatabase.instance.ref(); // real time firebase object
  // ignore: prefer_typing_uninitialized_variables
  var listener;
  Map<String, dynamic> settingData = {};

  // variables area

  // additional variables
  bool hidePassword = false; //
  bool rememberMe = false;
  bool sendNewUser = false;
  bool mainDrawerValuesListBool = false;
  bool mainDrawerFarmsListBool = false;
  int currentPage = 0;
  bool networkConnection = true;
  bool timerListener = false;
  // devices variables
  List<Device> devices = [];

  String espTime = "";
  bool isEspConnected = false;
  List<double> tempReading = [];
  List<double> humReading = [];
  List<double> airQuality = [];
  String airQualityText = "---";
  var maxTempController = TextEditingController();
  var minTempController = TextEditingController();
  var maxVentController = TextEditingController();
  var minVentController = TextEditingController();
  var delayController = TextEditingController();
  var historicalDelayController = TextEditingController();
  int usersCount = 1;
  int lastKeepAliveValue = 0;
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

  /// data reading
  void checkKeepAlive(int allState) async {
    print("checkKeepAlive");
    print((int.parse(delayController.text) + 1));
    if (allState == 1 && timerListener == false) {
      timerListener = true;
      isEspConnected = true;
      Timer.periodic(Duration(minutes: int.parse(delayController.text) + 1),
          (Timer t) {
        if (uId == "") {
          t.cancel();
          return;
        }
        dataBase.child(uId).get().then((value) {
          int currentKeepAlive =
              value.child('Time').child("Minute").value! as int;
          print("currentKeepAlive $currentKeepAlive");
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

  void readFireDataOnce() {
    print("readFireDataOnce");
    print(uId);
    tempReading = [];
    humReading = [];
    emit(GetDataLoading());
    dataBase.child(uId).once().then((snap) {
      dynamic data = (snap.snapshot.value);

      tempReading = objectsToList(data['Temp']?.values?.toList(), 1);
      humReading = objectsToList(data['Hum']?.values?.toList(), 1);
      airQuality = objectsToList(data['airQuality']?.values?.toList(), 1);
      airQualityText = airRatioToText(airQuality.average.round());
      Map tempEspTime = data['Time'];
      print(tempEspTime);
      espTime =
          "${tempEspTime['Hour']}:${tempEspTime['Minute']}:${tempEspTime['Seconds']}";
      if (int.tryParse(tempEspTime['Minute'].toString()) != null) {
        lastKeepAliveValue =
            int.tryParse(tempEspTime['Minute'].toString())! - 1;
      }
      settingData = Map<String, dynamic>.from(data['config'] ?? {});

      dynamic devicesData = data['states'] ?? {};
      devices = [];
      devicesData.forEach((key, value) {
        if (!key.contains("Auto")) {
          devices.add(Device(
              state: texToState[value]!,
              name: key.replaceAll("_", " "),
              isAuto: devicesData[key + "_Auto"] == "ON"));
        }
      });

      maxTempController.text = '${data['valueRanges']['temp'].split(',')[1]}';
      minTempController.text = '${data['valueRanges']['temp'].split(',')[0]}';
      maxVentController.text = '${data['valueRanges']['vent'].split(',')[1]}';
      minVentController.text = '${data['valueRanges']['vent'].split(',')[0]}';
      delayController.text = "${data['valueRanges']['delay']}";
      checkKeepAlive(1);

      historicalDelayController.text = "${data['valueRanges']['timeToWait']}";
      currentUserName = data['RFID']['data'].split(',')[0];
      currentUserImageUrl = driveToImage(data['RFID']['data'].split(',')[1]);
      currentUserId = "${data['RFID']['lastID'].split(',')[0]}";
      currentUserState = "${data['RFID']['lastID'].split(',')[1]}";
      emit(GetDataDone());
    }).catchError((err, stack) {
      print(err);
      print(stack);
    });
  }

  void readFireDataListener() {
    listener = dataBase.child(uId).onChildChanged.listen((event) {
      dynamic data = event.snapshot.value;

      switch (event.snapshot.key) {
        case 'states':
          {
            devices = [];

            data.forEach((key, value) {
              if (!key.contains("Auto")) {
                devices.add(Device(
                    state: texToState[value]!,
                    name: key.replaceAll("_", " "),
                    isAuto: data[key + "_Auto"] == "ON"));
              }
            });
            break;
          }
        case 'Hum':
          {
            humReading = objectsToList(data.values.toList(), 1);
            break;
          }
        case 'Temp':
          {
            tempReading = objectsToList(data.values.toList(), 1);
            break;
          }
        case 'Time':
          {
            espTime = "${data['Hour']}:${data['Minute']}:${data['Seconds']}";
            lastKeepAliveValue = -1;
            isEspConnected = true;
            checkKeepAlive(1);
            break;
          }
        case "airQuality":
          {
            airQuality = objectsToList(data['airQuality']?.values?.toList(), 1);
            airQualityText = airRatioToText(airQuality.average.round());
            break;
          }

        case "RFID":
          {
            currentUserName = data['data'].split(',')[0];
            currentUserImageUrl = driveToImage(data['data'].split(',')[1]);
            currentUserId = "${data['lastID'].split(',')[0]}";
            currentUserState = "${data['lastID'].split(',')[1]}";
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

  List<double> objectsToList(List? oldList, int ratio) {
    if (oldList == null) return [];
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

  /// firebase database functions

  void deviceStatus(int index) {
    bool isAuto = devices[index].isAuto;

    if (!isAuto) {
      DeviceState lastState = devices[index].state;
      String state;
      if (lastState == DeviceState.on) {
        state = "OFF";
      } else if (lastState == DeviceState.off) {
        state = "ON";
      } else {
        errorToast("Can't control the device now");
        return;
      }
      print(state);
      dataBase.child(uId).child('controls').update(
          {devices[index].name.replaceAll(" ", "_"): state}).then((value) {
        emit(ChangeDeviceStatus());
        devices[index].state = DeviceState.wait;
      }).catchError((err) {
        errorToast("an error happened");
      });
    } else {
      errorToast("device is Automatic");
    }
  }

  void deviceAutoStatus(int index) {
    bool lastState = devices[index].isAuto;
    dataBase.child(uId).child('states').update({
      devices[index].name.replaceAll(" ", "_") + "_Auto":
          !lastState ? "ON" : "OFF"
    }).then((value) {
      emit(ChangeDeviceStatus());
      devices[index].isAuto = !devices[index].isAuto;
    }).catchError((err) {
      errorToast("an error happened");
    });
  }

  // void ledStatus(int index) {
  //   String state;
  //   if (leds[index].state == DeviceState.on) {
  //     state = "OFF";
  //   } else if (leds[index].state == DeviceState.off) {
  //     state = "ON";
  //   } else {
  //     errorToast("Can't control the device now");
  //     return;
  //   }
  //   leds[index].state = DeviceState.wait;
  //   print(state);
  //   dataBase
  //       .child(uId)
  //       .child('controls')
  //       .child("leds")
  //       .update({"led${index + 1}": state}).then((value) {
  //     emit(ChangeDeviceStatus());
  //   }).catchError((err) {
  //     errorToast("an error happened");
  //   });
  //   emit(ChangeDeviceStatus());
  // }

  void sendValuesRanges() {
    dataBase.child(uId).child("config").update(settingData);
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
    dataBase.child(uId).update({'resetFlag': "ON"}).then((value) {
      infoToast('ESP reset successfully');
      emit(SendDataToFireState());
    }).catchError((err) {
      errorToast("An error Happened");
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
      dataBase.child(uId).update({'configFlag': 'ON'});
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
        dataBase.child(uId).update({'configFlag': "ON"});
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

  void addFarmDevise() {
    usersCount++;
    for (int i = 1; i < usersCount; i++) {
      dataBase
          .child(uId.split('_')[0] + '_$i')
          .update({'usersCount': usersCount});
    }
    _dataRepository.addNewUserData(usersCount);
    emit(AddFarmDeviseState());
  }

  Future<void> sendToEsp(
      BuildContext context, String wifiName, String wifiPassword) async {
    emit(SendConfigLoading());
    try {
      bool ret = await _webServices.sendConfig(wifiName, wifiPassword);
      if (ret) {
        currentPage = 0;
        navigateAndReplace(context, MainScreen(null));
        emit(SendConfigDone());
      } else {
        errorToast("Error happened ,make sure Your WIFI and pass is correct ");
        emit(SendConfigError());
      }
    } catch (_) {
      errorToast(
          "Error happened ,make sure you connect to ESP wifi and try again");
      emit(SendConfigError());
    }
  }

  /// data sheet functions
  Future<void> deleteDataSheet() async {
    emit(DeleteSheetLoading());
    try {
      await _webServices.deleteDataSheet();
      realNumberOfGraphedData = 0;
      allGraphDataList = [
        ["Date"]
      ];
      emit(DeleteSheetDone());
    } catch (err) {
      emit(DeleteSheetError());
    }
  }

  Future<void> readDataForGraph(int length) async {
    emit(GetAllGraphDataLoading());
    try {
      String value = await _webServices.getGraphSensorsData(length);
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
          print(list);
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
    } catch (err) {
      errorToast("Error happened Please Try again");
    }
  }

  Future<void> getAllSensorsData() async {
    emit(GetAllGraphDataLoading());
    try {
      allGraphDataList = await _webServices.getAllSensorsData();
    } catch (err) {
      errorToast("Error happened Please Try again");
    }
    emit(GetAllGraphDataDone());
  }

  void toCsv() async {
    emit(CsvPrepare());
    await _webServices.saveCSV();
    emit(CsvPrepared());
  }

  /// RFID data functions
  String driveToImage(String driveUrl) {
    String imageUrl = '';
    if (driveUrl.contains('drive.google.com')) {
      driveUrl.split('/')[3];
    }
    return imageUrl;
  }

  Future<void> editEmployee(
      Map<String, dynamic> data, BuildContext context) async {
    emit(SendToEditLoading());
    try {
      await _webServices.editEmployee(data);
      activeUser = -1;
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
    } catch (e) {
      emit(SendToEditError());
      errorToast('An error happened');
    }
  }

  Future<void> deleteEmployee(int userIndex, BuildContext context) async {
    emit(DeleteEmployeeLoading());
    try {
      await _webServices.deleteEmployee(userIndex);
      employeesNamesList.removeAt(userIndex - 1);
      activeUser = -1;
      Navigator.of(context).pop();
      emit(DeleteEmployeeDone());
    } catch (err) {
      errorToast("An error happened");
      emit(GetPersonError());
    }
  }

  Future<void> getEmployeeData(int index, BuildContext context,
      {bool edit = false}) async {
    emit(GetPersonLoading());

    if (index != activeUser || userData.isEmpty) {
      try {
        userData = await _webServices.getEmployeeData(index);
        activeUser = index;
      } catch (err) {
        emit(GetPersonError());
      }
    }

    if (!edit) {
      navigateAndPush(context, UserScreen(index));
    }
    emit(GetPersonDone());
  }

  Future<void> getEmployeeNames() async {
    emit(GetEmployeeNamesLoading());
    try {
      employeesNamesList = await _webServices.getEmployeesNames();
      if (employeesNamesList.isEmpty) {
        thereEmployee = false;
      }
      emit(GetEmployeeNamesDone());
    } catch (err) {
      errorToast("An error happen");
      emit(GetEmployeeNamesError());
    }
  }

  /// Signing functions
  Future<void> valuesToDefault() async {
    listener.cancel();
    listener = null;
    espTime = "";
    uId = "";
    thereEmployee = true;
    employeesNamesList = [];
    mainDrawerValuesListBool = false;
    mainDrawerFarmsListBool = false;
    currentPage = 0;
    isEspConnected = false;
    timerListener = false;
    _webServices.allGraphData = "";
    allGraphDataList = [];
    activeUser = -1;
    userData = {};
    numberOfGraphedData = 0;
    realNumberOfGraphedData = -1;
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

  void getUserLoginData(bool? checkRemember) async {
    emit(CheckUserStateLoading());
    final prefs = await SharedPreferences.getInstance();
    if (checkRemember == true) {
      uId = prefs.getString("uId")!;
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

  void unSubscribe() {
    FirebaseMessaging.instance.unsubscribeFromTopic(uId.split("_")[0]);
  }

  void supScribe() {
    FirebaseMessaging.instance.subscribeToTopic(uId.split("_")[0]);
  }

  void logOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    unSubscribe();
    valuesToDefault();
    prefs.clear();
    navigateAndReplace(context, LoginPage());
  }

  Future<void> virtualLogOutThenIn(BuildContext context, String nextId) async {
    valuesToDefault();
    uId = nextId;
    readFireDataOnce();
    readFireDataListener();
    currentPage = 0;
    emit(UserSignUpDone());
    Navigator.of(context).pop();
  }

  void forgetPassword(BuildContext context, String email) async {
    emit(UserSignUpLoading());
    try {
      _auth.forgetPassword(email);
      emit(UserSignUpDone());
    } on FireBaseAuthErrors catch (_) {
      emit(UserForgetPassError());
    }
  }

  void signIn(BuildContext context, String email, String password) async {
    emit(UserSignInLoading());
    try {
      _auth.signInWithEmailAndPassword(email, password);
    } on FireBaseAuthErrors catch (e) {
      emit(UserSignInError());
      errorToast(e.message);
    }

    if (_auth.uid == null) {
      emit(UserSignUpError());
      return;
    }

    uId = _auth.uid! + '_1';
    readFireDataOnce();
    readFireDataListener();
    supScribe();
    saveData(uId);
    currentPage = 0;
    navigateAndReplace(context, MainScreen(null));
    emit(UserSignUpDone());
  }

  void signUp(BuildContext context, String email, String password) async {
    emit(UserSignUpLoading());
    try {
      await _auth.signUpWithEmailAndPassword(email: email, password: password);
      emit(UserVerifyLoading());
      Future.delayed(const Duration(seconds: 3), () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    } on FireBaseAuthErrors catch (e) {
      emit(UserSignUpError());
      errorToast(e.message);
      return;
    }

    if (_auth.uid == null) {
      emit(UserSignUpError());
      return;
    }
    uId = _auth.uid! + '_1';
    _dataRepository.addNewUserData(usersCount);
    emit(UserSignUpDone());
  }

  /// ui update functions
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

enum DeviceState { on, off, rst, wait }

extension Gets on DeviceState {
  Color get getColor {
    switch (this) {
      case DeviceState.on:
        return Colors.green;
      case DeviceState.off:
        return Colors.red;
      case DeviceState.rst:
        return Colors.yellow;
      case DeviceState.wait:
        return Colors.blue;
    }
  }

  String get geText {
    switch (this) {
      case DeviceState.on:
        return "ON";
      case DeviceState.off:
        return "OFF";
      case DeviceState.rst:
        return "Reset";
      case DeviceState.wait:
        return "Wait";
    }
  }
}

Map<String, DeviceState> texToState = {
  "ON": DeviceState.on,
  "OFF": DeviceState.off,
  "RST": DeviceState.rst,
};

class Device {
  DeviceState state;
  String name;
  bool isAuto;

  Device({required this.state, required this.name, required this.isAuto});
}
