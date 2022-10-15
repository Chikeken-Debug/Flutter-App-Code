import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../cubit/schedule_cubit.dart';
import '../../cubit/states.dart';
import '../../model/modules/event_data.dart';
import '../../reusable/reusable_functions.dart';
import 'bottom_sheet.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime now = DateTime.now();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleCubit, AppStates>(
      listener: (BuildContext context, AppStates state) {},
      builder: (BuildContext context, AppStates state) {
        ScheduleCubit cubit = ScheduleCubit.get(context);
        Duration diff = DateTime.now().difference(_selectedDay ?? now);
        bool newDate = diff.isNegative || diff.inDays == 0;

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: const Text(
              "Farm Tasks",
              style: TextStyle(color: Colors.green),
            ),
          ),
          floatingActionButton: newDate
              ? FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      barrierColor: Colors.white.withOpacity(0.8),
                      elevation: 20,
                      isScrollControlled: true,
                      //constraints: const BoxConstraints(maxHeight: 650),
                      backgroundColor: Colors.white,
                      builder: (context) => BottomSheetLayout(
                          _selectedDay ?? now, false, null, null),
                    );
                  },
                  child: const Icon(
                    Icons.add,
                    size: 40,
                  ),
                )
              : null,
          body: state is ScheduleAppLoadingState
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      TableCalendar(
                        headerStyle: const HeaderStyle(
                            titleCentered: true, formatButtonVisible: false),
                        firstDay:
                            DateTime.utc(now.year - 1, now.month, now.day),
                        lastDay: DateTime.utc(now.year + 1, now.month, now.day),
                        focusedDay: _focusedDay,
                        startingDayOfWeek: StartingDayOfWeek.saturday,
                        calendarFormat: CalendarFormat.month,
                        calendarStyle: const CalendarStyle(
                          outsideDaysVisible: false,
                          markerDecoration: BoxDecoration(
                              color: Colors.black, shape: BoxShape.circle),
                          selectedDecoration: BoxDecoration(
                              color: Colors.green, shape: BoxShape.circle),
                          todayDecoration: BoxDecoration(
                              color: Colors.blueGrey, shape: BoxShape.circle),
                        ),
                        eventLoader: (DateTime date) {
                          return cubit.eventsData
                              .where((EventData element) =>
                                  isSameDay(date, element.day))
                              .toList();
                        },
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          if (!isSameDay(_selectedDay, selectedDay)) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          }
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                      ),
                      dayTasks(cubit, _selectedDay ?? DateTime.now())
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget dayTasks(ScheduleCubit cubit, DateTime date) {
    List<EventData> data = cubit.eventsData
        .where((EventData element) => isSameDay(date, element.day))
        .toList();
    Duration diff = date.difference(now);
    int daysLeft = diff.inDays;
    if (daysLeft == 0 || !diff.isNegative) {
      if (isSameDay(now, date)) {
        daysLeft = 0;
      } else {
        daysLeft++;
      }
    }

    return Container(
      color: const Color(0xffECECEC),
      child: Column(
        children: [
          Container(
            height: 30,
            decoration: const BoxDecoration(color: Colors.black45),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Tasks',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
                Text(
                  DateFormat('dd-MM-yyyy').format(date),
                  style: const TextStyle(
                      //fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
                DefaultTextStyle(
                  style: const TextStyle(
                      color: Colors.white,
                      //fontWeight: FontWeight.bold,
                      fontSize: 18),
                  child: daysLeft == 0
                      ? const Text(
                          "[ Today ]",
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("[ "),
                            Text(
                              "${daysLeft.abs()}",
                            ),
                            const Text(' Day'),
                            Text(daysLeft.abs() == 1 ? "" : "s"),
                            Text(' ${daysLeft.isNegative ? "pass" : "left"} ]'),
                          ],
                        ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          data.isEmpty
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.circle,
                          size: 15,
                          color: Colors.green,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text('Active'),
                      ],
                    ),
                    Row(
                      children: const [
                        Icon(
                          Icons.circle,
                          size: 15,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text('Waiting'),
                      ],
                    ),
                    Row(
                      children: const [
                        Icon(
                          Icons.circle,
                          size: 15,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text('Ended'),
                      ],
                    ),
                  ],
                ),
          data.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.format_list_numbered,
                        size: 40,
                      ),
                      Text(
                        "  No Tasks",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    EventData event = data[index];
                    String formattedStart = event.startTime.format(context);
                    String formattedEnd = event.endTime.format(context);

                    return Dismissible(
                      background: Container(
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      key: UniqueKey(),
                      confirmDismiss: (_) async {
                        if (event.state == EventState.running) {
                          errorToast("Task is running");
                          return Future.value(false);
                        }
                        return (await showDialog<bool?>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Warning"),
                                content: const Text("Delete the Task ?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("NO"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text("YES"),
                                  ),
                                ],
                              ),
                            )) ??
                            false;
                      },
                      onDismissed: (_) {
                        cubit.deleteTask(index: index, id: event.id);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Deleted successfully'),
                          duration: Duration(seconds: 1),
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListTile(
                          onTap: () {
                            if (event.state == EventState.waiting) {
                              showModalBottomSheet(
                                context: context,
                                barrierColor: Colors.white.withOpacity(0.8),
                                elevation: 20,
                                isScrollControlled: true,
                                //constraints: const BoxConstraints(maxHeight: 650),
                                backgroundColor: Colors.white,
                                builder: (context) => BottomSheetLayout(
                                    event.day, true, index, event),
                              );
                            }
                          },
                          isThreeLine: true,
                          leading: CircleAvatar(
                            backgroundColor: {
                              EventState.running: Colors.green[200],
                              EventState.waiting: Colors.white.withOpacity(0.8),
                              EventState.done: Colors.grey.withOpacity(0.5)
                            }[event.state],
                            child: Text("${index + 1}"),
                          ),
                          title: Text(event.device ?? ""),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Start at $formattedStart End at $formattedEnd"),
                              Row(
                                children: [
                                  const Text("Duration : "),
                                  Text(
                                    cubit.minutesFormatted(
                                        cubit.differentTimeMinutes(
                                            event.startTime, event.endTime)),
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                              event.state == EventState.running
                                  ? Row(
                                      children: [
                                        const Text("End in "),
                                        Text(
                                          cubit.minutesFormatted(
                                              cubit.differentTimeMinutes(
                                                  TimeOfDay.now(),
                                                  event.endTime)),
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              event.state == EventState.waiting &&
                                      isSameDay(now, event.day)
                                  ? Row(
                                      children: [
                                        const Text("Start in : "),
                                        Text(
                                          cubit.minutesFormatted(
                                              cubit.differentTimeMinutes(
                                                  TimeOfDay.now(),
                                                  event.startTime)),
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              event.state == EventState.done &&
                                      isSameDay(now, event.day)
                                  ? Row(
                                      children: [
                                        const Text("Ended from : "),
                                        Text(
                                          cubit.minutesFormatted(
                                              cubit.differentTimeMinutes(
                                                  event.endTime,
                                                  TimeOfDay.now())),
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Divider(
                        color: Colors.grey,
                      ),
                    );
                  },
                  itemCount: data.length),
        ],
      ),
    );
  }

  //     cubit.editTask(
//                                     selectedDay: date,
//                                     start: event.startTime,
//                                     end: TimeOfDay(
//                                         hour: TimeOfDay.now().hour - 1,
//                                         minute: 0),
//                                     context: context,
//                                     index: index,
//                                     id: event.id);
}
