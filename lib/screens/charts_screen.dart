import 'package:bird_system/cubit/cubit.dart';
import 'package:bird_system/cubit/states.dart';
import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:bird_system/screens/table_screen.dart';
import 'package:draw_graph/draw_graph.dart';
import 'package:draw_graph/models/feature.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class ChartScreen extends StatelessWidget {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<Color> graphColor = [
    Colors.green,
    Colors.blue,
    Colors.pink,
    Colors.orangeAccent,
    Colors.teal,
    Colors.grey
  ];

  ChartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (BuildContext context, AppStates state) {},
      builder: (BuildContext context, AppStates state) {
        AppCubit cubit = AppCubit.get(context);

        if (cubit.numberOfGraphedData == 0 &&
            state is! GetAllGraphDataLoading) {
          cubit.readDataForGraph(20);
        }

        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            cubit.numberOfGraphedData == 0 && cubit.realNumberOfGraphedData != 0
                ? Center(child: CircularProgressIndicator())
                : SmartRefresher(
                    enablePullUp: false,
                    controller: _refreshController,
                    onRefresh: () async {
                      cubit.readDataForGraph(20).then((value) {
                        Future.delayed(Duration(milliseconds: 1000))
                            .then((value) {
                          _refreshController.refreshCompleted();
                        });
                      });
                    },
                    child: cubit.realNumberOfGraphedData == 0
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.insert_chart_outlined_rounded,
                                  color: Colors.grey,
                                  size: 100,
                                ),
                                Text(
                                  'No Data',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                )
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 15),
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      height: 280,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 3,
                                              blurRadius: 4,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                          border: Border.all(
                                            color: customViolet,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      child: Column(
                                        children: [
                                          Text(
                                            "Temperature Sensors graphs",
                                            style: TextStyle(
                                                color: customViolet,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Expanded(
                                            child: PageView(
                                              children: [
                                                Stack(
                                                  alignment: Alignment.topRight,
                                                  children: [
                                                    LineGraph(
                                                      features: [
                                                        Feature(
                                                          title: "Average",
                                                          color: Colors.blue,
                                                          data: cubit.tempAvg,
                                                        ),
                                                      ],
                                                      size: Size(
                                                          double.infinity, 225),
                                                      labelX: List<
                                                              String>.filled(
                                                          cubit
                                                              .numberOfGraphedData,
                                                          ''),
                                                      labelY: [
                                                        '${((2 * int.parse(cubit.maxTempController.text) - int.parse(cubit.minTempController.text)) / 4).round()} c',
                                                        '${((2 * int.parse(cubit.maxTempController.text) - int.parse(cubit.minTempController.text)) / 2).round()} c',
                                                        '${((2 * int.parse(cubit.maxTempController.text) - int.parse(cubit.minTempController.text)) / 1.25).round()} c',
                                                        '${2 * int.parse(cubit.maxTempController.text) - int.parse(cubit.minTempController.text)} c'
                                                      ],
                                                      showDescription: false,
                                                      graphColor: Colors.black,
                                                      graphOpacity: 0.1,
                                                      verticalFeatureDirection:
                                                          false,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        'Average',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.blue),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Stack(
                                                  alignment: Alignment.topRight,
                                                  children: [
                                                    LineGraph(
                                                      features: cubit.tempGraph
                                                          .map((item) {
                                                        int i = cubit.tempGraph
                                                            .indexOf(item);
                                                        if (i > 6) {
                                                          i -= 6;
                                                        }
                                                        return Feature(
                                                            title: "T$i",
                                                            color:
                                                                graphColor[i],
                                                            data: cubit
                                                                .objectsToList(
                                                                    item, -1));
                                                      }).toList(),
                                                      size: Size(
                                                          double.infinity, 225),
                                                      labelX: List<
                                                              String>.filled(
                                                          cubit
                                                              .numberOfGraphedData,
                                                          ''),
                                                      labelY: [
                                                        '${((2 * int.parse(cubit.maxTempController.text) - int.parse(cubit.minTempController.text)) / 4).round()} c',
                                                        '${((2 * int.parse(cubit.maxTempController.text) - int.parse(cubit.minTempController.text)) / 2).round()} c',
                                                        '${((2 * int.parse(cubit.maxTempController.text) - int.parse(cubit.minTempController.text)) / 1.25).round()} c',
                                                        '${2 * int.parse(cubit.maxTempController.text) - int.parse(cubit.minTempController.text)} c'
                                                      ],
                                                      graphColor: Colors.black,
                                                      graphOpacity: 0.1,
                                                      verticalFeatureDirection:
                                                          false,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        'ALL readings',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.blue),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 15),
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      height: 280,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 3,
                                              blurRadius: 4,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                          border: Border.all(
                                            color: customViolet,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      child: Column(
                                        children: [
                                          Text(
                                            "Humidity Sensors graphs",
                                            style: TextStyle(
                                                color: customViolet,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Expanded(
                                            child: PageView(
                                              children: [
                                                Stack(
                                                  alignment: Alignment.topRight,
                                                  children: [
                                                    LineGraph(
                                                      features: [
                                                        Feature(
                                                            title: "Average",
                                                            color: Colors.green,
                                                            data: cubit.humAvg)
                                                      ],
                                                      size: Size(
                                                          double.infinity, 225),
                                                      labelX: List<
                                                              String>.filled(
                                                          cubit
                                                              .numberOfGraphedData,
                                                          ''),
                                                      labelY: const [
                                                        '20%',
                                                        '40%',
                                                        '60%',
                                                        '80%',
                                                        '100%'
                                                      ],
                                                      graphColor: Colors.black,
                                                      graphOpacity: 0.1,
                                                      verticalFeatureDirection:
                                                          false,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        'Average',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.blue),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Stack(
                                                  alignment: Alignment.topRight,
                                                  children: [
                                                    LineGraph(
                                                      features: cubit.humGraph
                                                          .map((item) {
                                                        int i = cubit.humGraph
                                                            .indexOf(item);
                                                        if (i > 6) {
                                                          i -= 6;
                                                        }
                                                        return Feature(
                                                            title: "H$i",
                                                            color:
                                                                graphColor[i],
                                                            data: cubit
                                                                .objectsToList(
                                                                    item, 100));
                                                      }).toList(),
                                                      size: Size(
                                                          double.infinity, 225),
                                                      labelX: List<
                                                              String>.filled(
                                                          cubit
                                                              .numberOfGraphedData,
                                                          ''),
                                                      labelY: const [
                                                        '20%',
                                                        '40%',
                                                        '60%',
                                                        '80%',
                                                        '100%'
                                                      ],
                                                      graphColor: Colors.black,
                                                      graphOpacity: 0.1,
                                                      verticalFeatureDirection:
                                                          false,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        'ALL readings',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.blue),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 15),
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      height: 280,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: customViolet,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      child: Column(
                                        children: [
                                          Text(
                                            "Air Quality",
                                            style: TextStyle(
                                                color: customViolet,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          LineGraph(
                                            features: [
                                              Feature(
                                                title: "",
                                                color: Colors.grey,
                                                data: cubit.airQualityList,
                                              ),
                                            ],
                                            size: Size(double.infinity, 225),
                                            labelX: List<String>.filled(
                                                cubit.numberOfGraphedData, ''),
                                            labelY: const [
                                              '100',
                                              '200',
                                              '300',
                                              '400',
                                              '500',
                                              '600'
                                            ],
                                            showDescription: false,
                                            graphColor: Colors.black,
                                            graphOpacity: 0.1,
                                            verticalFeatureDirection: false,
                                          ),
                                        ],
                                      )),
                                )
                              ],
                            ),
                          ),
                  ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.green,
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      navigateAndPush(context, TableScreen());
                    },
                    icon: Icon(
                      Icons.table_rows_outlined,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
