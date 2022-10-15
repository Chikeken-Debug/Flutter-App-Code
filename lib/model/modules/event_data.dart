import 'package:bird_system/cubit/schedule_cubit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class EventData {
  late DateTime day;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  String? device;
  late String id;
  late EventState state;

  EventData(rowData, String dataId, ScheduleCubit cubit) {
    device = rowData['device'];
    id = dataId;
    day = DateFormat('yyyy-MM-dd').parse(rowData['date']);
    final format = DateFormat.jm();
    startTime = TimeOfDay.fromDateTime(format.parse(rowData['startTime']));
    endTime = TimeOfDay.fromDateTime(format.parse(rowData['endTime']));

    // if not today
    DateTime today = DateTime.now();
    if (isSameDay(today, day)) {
      // may be done - waiting , running
      TimeOfDay now = TimeOfDay.now();
      if (cubit.differentTimeMinutes(now, startTime) > 0) {
        state = EventState.waiting;
      } else if (cubit.differentTimeMinutes(endTime, now) > 0) {
        state = EventState.done;
      } else {
        state = EventState.running;
      }

      ///
    } else {
      // may be old or new
      bool isOld = today.difference(day).isNegative;
      if (isOld) {
        state = EventState.waiting;
      } else {
        state = EventState.done;
      }
    }
  }
}

enum EventState { waiting, running, done }
