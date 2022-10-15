import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../cubit/app_cubit.dart';
import 'package:http/http.dart' as http;

import '../../reusable/reusable_functions.dart';

const _base = "https://script.google.com/macros/s/";

const _sheetRFID =
    "AKfycbxjeykhu5BpiraSKXN_ugb-oz6_3nSC51_Oc_-zMcNywjLttXFMXJ-S0Qb3en6Y7hRS";
const _dataSheet =
    "AKfycbwnPWp-hpkaF7RCMeWMBkYPxvx4_9z6Wlqz5soTzwsNukFcP3Qm6CWkUOBWDLOUderXjw";

const _rfidSheetLinkBase = _base + _sheetRFID + "/exec?";
const _dataSheetLinkBase = _base + _dataSheet + "/exec?";

class WebServices {
  String allGraphData = "";
  String get _id => AppCubit.uId;

  Future<List<List>> getAllSensorsData() async {
    var url =
        Uri.parse(_dataSheetLinkBase + "datalength=10&uid=$_id&alldatabool=1");
    String value = await http.read(url);
    if (value.contains("has not a previous Data")) {
      infoToast("no data yet");
      return [];
    }
    int numberOfRows = int.parse(value.split('] [[')[0].split('=[')[1]);
    value = value.split('[[')[1];
    value = value.replaceAll('],[', '\n');
    value = value.replaceAll(']]', '');
    allGraphData = value;
    List<List> allGraphDataList =
        CsvToListConverter(eol: '\n').convert(allGraphData);
    if (numberOfRows > 60) {
      List title = allGraphDataList[0];
      allGraphDataList =
          allGraphDataList.sublist(numberOfRows - 60, numberOfRows + 1);
      allGraphDataList.add(title);
    } else {
      allGraphDataList.add(allGraphDataList[0]);
      allGraphDataList.removeAt(0);
    }

    return allGraphDataList;
  }

  Future<String> getGraphSensorsData(int length) async {
    var url = Uri.parse(
        _dataSheetLinkBase + "datalength=$length&uid=$_id&alldatabool=0");

    String value = await http.read(url);
    return value;
  }

  Future<void> deleteDataSheet() async {
    var url =
        Uri.parse(_dataSheetLinkBase + "datalength=0&uid=$_id&alldatabool=2");
    await http.read(url);
  }

  Future<Map<String, dynamic>> getEmployeeData(int index) async {
    var url = Uri.parse(_rfidSheetLinkBase +
        "uid=$_id&fun=getdata&cardid=18010102&persondata=zzzz&index=$index");
    String value = await http.read(url);

    value = '{"' + value + '"}';
    value = value.replaceAll(':,', ':NULL,');
    value = value.replaceAll(':', '":"');
    value = value.replaceAll(',', '","');
    return json.decode(value);
  }

  Future<void> deleteEmployee(int index) async {
    var url = Uri.parse(_rfidSheetLinkBase +
        "uid=$_id&fun=delete&cardid=18010102&persondata=zzzz&index=$index");
    await http.read(url);
  }

  Future<void> editEmployee(Map<String, dynamic> data) async {
    var url = Uri.parse(_rfidSheetLinkBase +
        "uid=$_id&fun=add&cardid=${data['ID']}&persondata=$data&index=2");
    await http.read(url);
  }

  Future<List<String>> getEmployeesNames() async {
    var url = Uri.parse(_rfidSheetLinkBase +
        "uid=$_id&fun=getnames&cardid=18010102&persondata=zzzz&index=2");
    String value = await http.read(url);

    if (value.startsWith('[[')) {
      value = value.replaceAll('[["', '');
      value = value.replaceAll('"]]', '');
      return value.split('"],["');
    }
    return [];
  }

  Future<void> saveCSV() async {
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
      newPath = newPath + "/FarmArt";
      dir = Directory(newPath);
      if (await dir.exists()) {
        File saveFile = File(dir.path + '/Data.csv');
        saveFile.writeAsString(allGraphData);
        infoToast("file saved successfully");
      } else {
        Directory(newPath).create().then((value) {
          File saveFile = File(value.path + '/Data.csv');
          saveFile.writeAsString(allGraphData);
          infoToast("file saved successfully");
        }).catchError((err) {
          errorToast("an error Happened");
        });
      }
    } else {
      errorToast("Permission refused");
    }
  }

  Future<bool> sendConfig(String name, String pass) async {
    var url =
        Uri.parse('http://192.168.4.1/data?user=$_id&wifi=$name&pass=$pass');
    String value = await http.read(url);

    if (value.trim() != "Failed") {
      return true;
    } else {
      return false;
    }
  }
}
