import 'package:bird_system/cubit/app_cubit.dart';
import 'package:bird_system/cubit/schedule_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../cubit/states.dart';
import '../../model/modules/event_data.dart';
import '../../reusable/reusable_functions.dart';

// ignore: must_be_immutable
class BottomSheetLayout extends StatefulWidget {
  BottomSheetLayout(this.date, this.edit, this.index, this.eventData,
      {Key? key})
      : super(key: key);
  DateTime date;
  bool edit = false;
  EventData? eventData;
  int? index;

  @override
  // ignore: no_logic_in_create_state
  State<BottomSheetLayout> createState() => _BottomSheetLayoutState(date);
}

class _BottomSheetLayoutState extends State<BottomSheetLayout> {
  String? description;
  TimeOfDay? start;
  TimeOfDay? end;
  DateTime date;
  int? differentTime;
  late int daysLeft;

  _BottomSheetLayoutState(this.date) {
    DateTime now = DateTime.now();
    daysLeft = date.difference(now).inDays;
    daysLeft = isSameDay(now, date) ? -1 : daysLeft;
    daysLeft++;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.edit) {
        start = widget.eventData!.startTime;
        end = widget.eventData!.endTime;
        description = widget.eventData!.device;
        differentTime =
            ScheduleCubit.get(context).differentTimeMinutes(start!, end!);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleCubit, AppStates>(
      listener: (BuildContext context, AppStates state) {},
      builder: (BuildContext context, AppStates state) {
        ScheduleCubit cubit = ScheduleCubit.get(context);
        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Add Task To  ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Text(
                        DateFormat('dd-MM-yyyy').format(date),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.green),
                      )
                    ],
                  ),
                  if (daysLeft == 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Today",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Days left : ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          "$daysLeft",
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        )
                      ],
                    ),
                  dropDownMenue(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 60,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: start == null
                              ? OutlinedButton.icon(
                                  onPressed: () async {
                                    start = await _selectTime(context, start);
                                    if (end != null) {
                                      differentTime = cubit
                                          .differentTimeMinutes(start!, end!);
                                    }
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.timer_outlined),
                                  label: const Text("Start Time"))
                              : InkWell(
                                  onTap: () async {
                                    start = await _selectTime(context, start);
                                    if (end != null) {
                                      differentTime = cubit
                                          .differentTimeMinutes(start!, end!);
                                    }
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.green),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Start Time',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Text(
                                          start!.format(context),
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        height: 60,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: end == null
                              ? OutlinedButton.icon(
                                  onPressed: () async {
                                    end = await _selectTime(context, end);
                                    if (start != null) {
                                      differentTime = cubit
                                          .differentTimeMinutes(start!, end!);
                                    }
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.timer_off_outlined),
                                  label: const Text("End time"))
                              : InkWell(
                                  onTap: () async {
                                    end = await _selectTime(context, end);
                                    if (start != null) {
                                      differentTime = cubit
                                          .differentTimeMinutes(start!, end!);
                                    }
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.green),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      children: [
                                        const Text(
                                          'End Time',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Text(
                                          end!.format(context),
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        differenceTimeWidget(cubit),
                        daysLeft == 0 && start != null
                            ? cubit.differentTimeMinutes(
                                        TimeOfDay.now(), start!) <
                                    0
                                ? const Text(
                                    "invalid start",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  )
                                : Row(
                                    children: [
                                      const Text("Start in "),
                                      Text(
                                        cubit.minutesFormatted(
                                            cubit.differentTimeMinutes(
                                                TimeOfDay.now(), start!)),
                                        style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    ],
                                  )
                            : Container(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            if (start == null || end == null) {
                              errorToast("Time can't be empty");
                            } else if (cubit.differentTimeMinutes(
                                    start!, end!) <=
                                0) {
                              infoToast("End time can't be before start");
                            } else if (daysLeft == 0 &&
                                cubit.differentTimeMinutes(
                                        TimeOfDay.now(), start!) <=
                                    0) {
                              errorToast("Start Time invalid");
                            } else {
                              if (widget.edit) {
                                cubit.editTask(
                                    selectedDay: date,
                                    start: start!,
                                    end: end!,
                                    context: context,
                                    description: description,
                                    id: widget.eventData!.id,
                                    index: widget.index!);
                              } else {
                                cubit.saveTask(
                                    selectedDay: date,
                                    start: start!,
                                    end: end!,
                                    context: context,
                                    description: description);
                              }
                            }
                          },
                          child: Text(
                            widget.edit ? "Edit" : "Save",
                            style: const TextStyle(fontSize: 18),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget differenceTimeWidget(ScheduleCubit cubit) {
    return differentTime == null
        ? Container()
        : differentTime! <= 0
            ? const Center(
                child: Text(
                  "invalid times",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              )
            : Row(
                children: [
                  const Text("Duration  : "),
                  Text(
                    cubit.minutesFormatted(differentTime!),
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ],
              );
  }

  Future<TimeOfDay?> _selectTime(
      BuildContext context, TimeOfDay? initialTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
    return pickedTime;
  }

  Widget dropDownMenue() {
    AppCubit cubit = AppCubit.get(context);
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: DropdownButtonFormField<String>(
        items: [
          ...List.generate(
              cubit.ledState.length,
              (i) => DropdownMenuItem(
                    child: Text("Led ${i + 1}"),
                    value: "led${i + 1}",
                  )),
          ...List.generate(
              cubit.fansBoolList.length,
              (i) => DropdownMenuItem(
                    child: Text("Fan ${i + 1}"),
                    value: "fan${i + 1}",
                  )),
          ...List.generate(
              cubit.fansBoolList.length,
              (i) => DropdownMenuItem(
                    child: Text("Heater ${i + 1}"),
                    value: "heater${i + 1}",
                  ))
        ],
        onChanged: (val) {
          description = val!;
        },
        value: widget.eventData?.device,
        decoration: InputDecoration(
          labelText: 'Device',
          prefixIcon: const Icon(Icons.message_outlined),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.green, width: 2.0),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
