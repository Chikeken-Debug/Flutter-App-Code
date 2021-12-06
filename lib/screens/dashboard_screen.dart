import 'package:bird_system/cubit/cubit.dart';
import 'package:bird_system/cubit/states.dart';
import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:collection/collection.dart';

// ignore: must_be_immutable
class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (BuildContext context, AppStates state) {},
      builder: (BuildContext context, AppStates state) {
        AppCubit cubit = AppCubit.get(context);

        if (cubit.espTime == "") {
          print("from here");
          cubit.readFireDataOnce();
          cubit.checkKeepAlive(0);
          if (cubit.listener == null) {
            cubit.readFireDataListener();
          }
        }

        return state is GetDataLoading || cubit.espTime == ""
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 4,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                            border: Border.all(
                              color: customViolet,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: PageView(
                          children: <Widget>[
                            cubit.tempReading.isEmpty
                                ? Center(
                                    child: Text(
                                      'No Sensors',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                "Temperature Sensors",
                                                style: TextStyle(
                                                    color: customViolet,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Expanded(
                                                child: ListView.builder(
                                                  itemCount:
                                                      cubit.tempReading.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 8.0,
                                                                vertical: 4),
                                                        child: Stack(
                                                          alignment: Alignment
                                                              .topRight,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 8.0),
                                                              child:
                                                                  SfLinearGauge(
                                                                showLabels:
                                                                    false,
                                                                minimum: 0,
                                                                maximum: double.parse(cubit
                                                                        .minTempController
                                                                        .text) +
                                                                    double.parse(cubit
                                                                        .maxTempController
                                                                        .text),
                                                                ranges: [
                                                                  LinearGaugeRange(
                                                                    startValue:
                                                                        0,
                                                                    endValue: cubit
                                                                            .tempReading[
                                                                        index],
                                                                  )
                                                                ],
                                                                markerPointers: [
                                                                  LinearShapePointer(
                                                                    value: cubit
                                                                            .tempReading[
                                                                        index],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Text(
                                                              '${cubit.tempReading[index]}',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                          ],
                                                        ));
                                                  },
                                                ),
                                              )
                                            ],
                                          )),
                                      Expanded(
                                        flex: 2,
                                        child: SfRadialGauge(
                                            title: GaugeTitle(
                                                text:
                                                    "Average Temp"), //title for guage
                                            enableLoadingAnimation: true,
                                            animationDuration:
                                                1000, //pointer movement speed
                                            axes: <RadialAxis>[
                                              RadialAxis(
                                                  minimum: 0,
                                                  maximum: double.parse(cubit
                                                          .minTempController
                                                          .text) +
                                                      double.parse(cubit
                                                          .maxTempController
                                                          .text),
                                                  ranges: <GaugeRange>[
                                                    GaugeRange(
                                                      startValue: 0,
                                                      endValue: double.parse(cubit
                                                          .minTempController
                                                          .text), //start and end point of range
                                                      color: Colors.green,
                                                    ),
                                                    GaugeRange(
                                                      startValue: double.parse(
                                                          cubit
                                                              .minTempController
                                                              .text),
                                                      endValue: double.parse(
                                                          cubit
                                                              .maxTempController
                                                              .text),
                                                      color: Colors.orange,
                                                    ),
                                                    GaugeRange(
                                                      startValue: double.parse(
                                                          cubit
                                                              .maxTempController
                                                              .text),
                                                      endValue: double.parse(cubit
                                                              .minTempController
                                                              .text) +
                                                          double.parse(cubit
                                                              .maxTempController
                                                              .text),
                                                      color: Colors.red,
                                                    )
                                                  ],
                                                  pointers: <GaugePointer>[
                                                    NeedlePointer(
                                                      value: cubit
                                                          .tempReading.average,
                                                    ) //add needlePointer here
                                                  ],
                                                  annotations: <
                                                      GaugeAnnotation>[
                                                    GaugeAnnotation(
                                                        widget: Text(
                                                            '${cubit.tempReading.average.round()}',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        angle: 90,
                                                        positionFactor: 0.75),
                                                  ])
                                            ]),
                                      )
                                    ],
                                  ),
                            cubit.humReading.isEmpty
                                ? Center(
                                    child: Text('No Sensors',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold)),
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                "Humidity Sensors",
                                                style: TextStyle(
                                                    color: customViolet,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Expanded(
                                                child: ListView.builder(
                                                  itemCount:
                                                      cubit.tempReading.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 8.0,
                                                                vertical: 4),
                                                        child: Stack(
                                                          alignment: Alignment
                                                              .topRight,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 8.0),
                                                              child:
                                                                  SfLinearGauge(
                                                                showLabels:
                                                                    false,
                                                                minimum: 0,
                                                                maximum: 100,
                                                                ranges: [
                                                                  LinearGaugeRange(
                                                                    startValue:
                                                                        0,
                                                                    endValue: cubit
                                                                            .humReading[
                                                                        index],
                                                                  )
                                                                ],
                                                                markerPointers: [
                                                                  LinearShapePointer(
                                                                    value: cubit
                                                                            .humReading[
                                                                        index],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Text(
                                                              '${cubit.humReading[index]}',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                          ],
                                                        ));
                                                  },
                                                ),
                                              )
                                            ],
                                          )),
                                      Expanded(
                                        flex: 2,
                                        child: SfRadialGauge(
                                            title: GaugeTitle(
                                                text:
                                                    "Average Hum"), //title for guage
                                            enableLoadingAnimation: true,
                                            animationDuration:
                                                1000, //pointer movement speed
                                            axes: <RadialAxis>[
                                              RadialAxis(
                                                  minimum: 0,
                                                  maximum: 100,
                                                  ranges: <GaugeRange>[
                                                    GaugeRange(
                                                      startValue: 0,
                                                      endValue:
                                                          33, //start and end point of range
                                                      color: Colors.green,
                                                    ),
                                                    GaugeRange(
                                                      startValue: 33,
                                                      endValue: 77,
                                                      color: Colors.orange,
                                                    ),
                                                    GaugeRange(
                                                      startValue: 77,
                                                      endValue: 100,
                                                      color: Colors.red,
                                                    )
                                                  ],
                                                  pointers: <GaugePointer>[
                                                    NeedlePointer(
                                                      value: cubit
                                                          .humReading.average,
                                                    ) //add needlePointer here
                                                  ],
                                                  annotations: <
                                                      GaugeAnnotation>[
                                                    GaugeAnnotation(
                                                        widget: Text(
                                                            '${cubit.humReading.average.round()}',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        angle: 90,
                                                        positionFactor: 0.75),
                                                  ])
                                            ]),
                                      )
                                    ],
                                  ),
                            Center(
                                child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Air Quality",
                                          style: TextStyle(
                                              color: customViolet,
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.air,
                                        color: customViolet,
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: SfLinearGauge(
                                      showLabels: false,
                                      showAxisTrack: false,
                                      maximum: 150,
                                      ranges: const [
                                        LinearGaugeRange(
                                            startWidth: 25,
                                            endWidth: 25,
                                            child: Center(child: Text('ok')),
                                            startValue: 0,
                                            endValue: 20,
                                            position:
                                                LinearElementPosition.outside,
                                            color: Color(0xff0DC9AB)),
                                        LinearGaugeRange(
                                            startWidth: 25,
                                            endWidth: 25,
                                            child:
                                                Center(child: Text('meduim')),
                                            startValue: 20,
                                            endValue: 50,
                                            position:
                                                LinearElementPosition.outside,
                                            color: Color(0xffFFC93E)),
                                        LinearGaugeRange(
                                            startWidth: 25,
                                            endWidth: 25,
                                            child: Center(child: Text('bad')),
                                            startValue: 50,
                                            endValue: 100,
                                            position:
                                                LinearElementPosition.outside,
                                            color: Colors.orange),
                                        LinearGaugeRange(
                                            startWidth: 25,
                                            endWidth: 25,
                                            child:
                                                Center(child: Text('danger')),
                                            startValue: 100,
                                            endValue: 150,
                                            position:
                                                LinearElementPosition.outside,
                                            color: Color(0xffF45656)),
                                      ],
                                      markerPointers: [
                                        LinearShapePointer(
                                          value: cubit.airQuality,
                                          position: LinearElementPosition.cross,
                                          shapeType:
                                              LinearShapePointerType.triangle,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "The Air is ${cubit.airQualityText} with ${cubit.airQuality.round()} ppm",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15),
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: customViolet,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text(
                                "Devices Status",
                                style: TextStyle(
                                    color: customViolet,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return deviceItemBuilder(index, cubit);
                                    },
                                    separatorBuilder: (context, index) {
                                      return SizedBox(
                                        width: 20,
                                      );
                                    },
                                    itemCount: 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15),
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: customViolet,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "Light Controls",
                                    style: TextStyle(
                                        color: customViolet,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "INSIDE",
                                          style: TextStyle(
                                              color: customGrey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        TextButton(
                                            child: Text(cubit.ledGetState[0] ? "on" : "off ",
                                                style: TextStyle(
                                                    color: cubit.ledGetState[0]
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontSize: 17)),
                                            style: ButtonStyle(
                                                padding:
                                                    MaterialStateProperty.all<EdgeInsets>(
                                                        EdgeInsets.all(15)),
                                                foregroundColor:
                                                    MaterialStateProperty.all<Color>(
                                                        customViolet),
                                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(18.0),
                                                        side: BorderSide(color: cubit.ledGetState[0] ? Colors.green : Colors.red)))),
                                            onPressed: () {
                                              if (cubit.isEspConnected) {
                                                cubit.ledStatus(0);
                                              } else {
                                                errorToast(
                                                    'No Device connected');
                                              }
                                            }),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 30,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "OUTSIDE",
                                          style: TextStyle(
                                              color: customGrey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        TextButton(
                                            child: Text(cubit.ledGetState[1] ? "on" : "off",
                                                style: TextStyle(
                                                    color: cubit.ledGetState[1]
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontSize: 17)),
                                            style: ButtonStyle(
                                                padding:
                                                    MaterialStateProperty.all<EdgeInsets>(
                                                        EdgeInsets.all(15)),
                                                foregroundColor:
                                                    MaterialStateProperty.all<Color>(
                                                        customViolet),
                                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(18.0),
                                                        side: BorderSide(color: cubit.ledGetState[1] ? Colors.green : Colors.red)))),
                                            onPressed: () {
                                              if (cubit.isEspConnected) {
                                                cubit.ledStatus(1);
                                              } else {
                                                errorToast(
                                                    'No Device connected');
                                              }
                                            }),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }

  Widget deviceItemBuilder(int index, AppCubit cubit) {
    List<String> label = ['HeaterA', 'HeaterB', 'Fan'];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                label[index],
                style: TextStyle(
                    color: customGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              CircleAvatar(
                radius: 25,
                backgroundColor: cubit.devicesBoolList[index]
                    ? Colors.green.withOpacity(0.4)
                    : Colors.red.withOpacity(0.4),
                child: IconButton(
                    iconSize: 35,
                    onPressed: () {
                      if (cubit.isEspConnected) {
                        cubit.deviceStatus(index);
                      } else {
                        errorToast('No Device connected');
                      }
                    },
                    icon: Icon(
                      cubit.devicesBoolList[index]
                          ? Icons.flash_on
                          : Icons.flash_off,
                      color: cubit.devicesBoolList[index]
                          ? Colors.green
                          : Colors.red,
                    )),
              ),
              SizedBox(
                height: 5,
              ),
              FlutterSwitch(
                  value: cubit.devicesAutoBoolList[index],
                  padding: 8.0,
                  showOnOff: true,
                  activeText: 'A',
                  inactiveText: 'M',
                  activeIcon: Icon(
                    Icons.brightness_auto_outlined,
                    size: 10,
                  ),
                  inactiveIcon: Icon(
                    Icons.precision_manufacturing_outlined,
                    size: 10,
                  ),
                  onToggle: (val) {
                    if (cubit.isEspConnected) {
                      cubit.deviceAutoStatus(index);
                    } else {
                      errorToast('No Device connected');
                    }
                  })
            ],
          )
        ],
      ),
    );
  }
}
