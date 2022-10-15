import 'package:bird_system/cubit/app_cubit.dart';
import 'package:bird_system/cubit/states.dart';
import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../model/modules/event_data.dart';

class ScheduleCubit extends Cubit<AppStates> {
  ScheduleCubit() : super(AppInitial());
  static ScheduleCubit get(context) => BlocProvider.of(context);

  final fireBase = FirebaseDatabase.instance.ref();
  bool thereNotification = false;
  List<EventData> eventsData = [];

  Future<void> startApp() async {
    emit(ScheduleAppLoadingState());
    DataSnapshot snapshot =
        await fireBase.child(AppCubit.uId).child("Schedule").get();
    dynamic data = (snapshot.value);
    data.forEach((key, value) {
      eventsData.add(EventData(value, key, this));
    });

    emit(ScheduleAppReadyState());
  }

  Future<void> saveTask(
      {required DateTime selectedDay,
      required TimeOfDay start,
      required TimeOfDay end,
      required BuildContext context,
      String? description}) async {
    if (description == null) {
      errorToast("Invalid device");
      return;
    }
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDay);
    String formattedStart = start.format(context);
    String formattedEnd = end.format(context);
    description = description == "" ? null : description;

    Map<String, dynamic> rowData = {
      "device": description ?? "No description",
      "date": formattedDate,
      "startTime": formattedStart,
      "endTime": formattedEnd,
    };
    String id = ((description ?? "") + formattedDate + formattedStart);
    eventsData.add(EventData(rowData, id, this));
    print("here");
    await fireBase.child(AppCubit.uId).child("Schedule").child(id).set(rowData);
    Navigator.pop(context);

    emit(AddTaskState());
  }

  Future<void> editTask(
      {required DateTime selectedDay,
      required TimeOfDay start,
      required TimeOfDay end,
      required BuildContext context,
      required int index,
      required String id,
      String? description}) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDay);
    String formattedStart = start.format(context);
    String formattedEnd = end.format(context);
    description = description == "" ? null : description;
    Map<String, dynamic> rowData = {
      "device": description ?? "No description",
      "date": formattedDate,
      "startTime": formattedStart,
      "endTime": formattedEnd,
      "id": id
    };
    await fireBase
        .child(AppCubit.uId)
        .child("Schedule")
        .child(id)
        .update(rowData);

    eventsData[index] = EventData(rowData, id, this);
    Navigator.pop(context);
    emit(AddTaskState());
  }

  Future<void> deleteTask(
      {required int index, required String id, String? description}) async {
    eventsData.removeAt(index);
    await fireBase.child(AppCubit.uId).child("Schedule").child(id).remove();

    emit(AddTaskState());
  }

  int differentTimeMinutes(TimeOfDay st, TimeOfDay en) {
    int startMinutes = (st.hour * 60 + st.minute);
    int endMinutes = (en.hour * 60 + en.minute);
    int difInMinutes = endMinutes - startMinutes;
    return difInMinutes;
  }

  String minutesFormatted(int total) {
    int minutes = 0;
    int hours = 0;

    if (total < 60) {
      return '$total m';
    } else {
      minutes = total % 60;
      hours = ((total - minutes) / 60).ceil();
    }
    return '$hours h $minutes m';
  }

  void setState() {
    emit(GeneralState());
  }
}
