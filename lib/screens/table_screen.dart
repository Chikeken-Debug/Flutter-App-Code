import 'package:bird_system/cubit/cubit.dart';
import 'package:bird_system/cubit/states.dart';
import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class TableScreen extends StatelessWidget {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  TableScreen({Key? key}) : super(key: key);
  double ratio = 5;
  double _baseScaleFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (BuildContext context, AppStates state) {},
      builder: (BuildContext context, AppStates state) {
        AppCubit cubit = AppCubit.get(context);
        if (cubit.allGraphData.isEmpty && state is! GetAllGraphDataLoading) {
          cubit.getAllSensorsData();
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            foregroundColor: Colors.white.withOpacity(0.7),
            title: Text('Chicken debug'),
            actions: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: state is CsvPrepare
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CupertinoActivityIndicator(),
                      )
                    : IconButton(
                        onPressed: () {
                          cubit.toCsv();
                        },
                        icon: Icon(Icons.file_download)),
              )
            ],
          ),
          body: cubit.allGraphData.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: Shimmer.fromColors(
                    baseColor: Colors.blueGrey,
                    highlightColor: Colors.white,
                    child: Center(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return dummyListViewCell(index - 1);
                        },
                        itemCount: 20,
                      ),
                    ),
                  ),
                )
              : SmartRefresher(
                  enablePullUp: false,
                  controller: _refreshController,
                  onRefresh: () async {
                    cubit.getAllSensorsData().then((value) {
                      Future.delayed(Duration(milliseconds: 1000))
                          .then((value) {
                        _refreshController.refreshCompleted();
                      });
                    });
                  },
                  child: cubit.allGraphDataList.length == 1
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.table_chart_outlined,
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
                      : GestureDetector(
                          onScaleStart: (details) {
                            _baseScaleFactor = ratio;
                          },
                          onScaleUpdate: (details) {
                            ratio = _baseScaleFactor * details.scale;
                          },
                          onScaleEnd: (details) {
                            cubit.emit(ChangeDeviceStatus());
                          },
                          child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Table(
                                        columnWidths: {
                                          0: FixedColumnWidth(30 * ratio),
                                        },
                                        defaultColumnWidth:
                                            FixedColumnWidth(24 * ratio),
                                        border: TableBorder.all(width: 1.0),
                                        children: cubit.allGraphDataList
                                            .map((item) {
                                              return TableRow(
                                                  children: item.map((row) {
                                                return Container(
                                                  width: 40 * ratio,
                                                  color: Colors.white,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Center(
                                                      child: Text(
                                                        row
                                                            .toString()
                                                            .replaceAll(
                                                                '-', '\n'),
                                                        style: TextStyle(
                                                            fontSize:
                                                                4 * ratio),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList());
                                            })
                                            .toList()
                                            .reversed
                                            .toList(),
                                      ),
                                    ),
                                    Visibility(
                                      visible:
                                          cubit.allGraphDataList.length > 60,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Download the file to see all data",
                                          style: TextStyle(
                                            color: customGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                        ),
                ),
        );
      },
    );
  }

  Widget dummyListViewCell(int index) {
    return index == -1
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    'Date',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Container(
                height: 20.0,
                width: 1.0,
                color: Colors.grey,
                margin: const EdgeInsets.only(
                  left: 10.0,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Time',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Container(
                height: 20.0,
                width: 1.0,
                color: Colors.grey,
                margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Reading',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 8.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 20.0,
                  width: 1.0,
                  color: Colors.grey,
                  margin: const EdgeInsets.only(
                    left: 10.0,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 8.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  height: 20.0,
                  width: 1.0,
                  color: Colors.grey,
                  margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 8.0,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          );
  }
}
