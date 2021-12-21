import 'dart:convert';

import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:bird_system/Layout/configuration_screen.dart';
import 'package:bird_system/Layout/rfid/card_screen.dart';
import 'package:bird_system/cubit/cubit.dart';
import 'package:bird_system/cubit/states.dart';
import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:bird_system/screens/charts_screen.dart';
import 'package:bird_system/screens/dashboard_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart'; // import this

// ignore: must_be_immutable
class MainScreen extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  var formKey = GlobalKey<FormState>();

  Map<String, dynamic>? notificationData;

  List<Widget> activeScreen = [DashBoardScreen(), ChartScreen()];

  MainScreen(String? notificationRowData, {Key? key}) : super(key: key) {
    if (notificationRowData != null) {
      try {
        notificationData = json.decode(notificationRowData);
      } catch (err) {
        notificationData = null;
      }
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove("notificationInfo");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (BuildContext context, AppStates state) {},
      builder: (BuildContext context, AppStates state) {
        AppCubit cubit = AppCubit.get(context);

        return cubit.networkConnection
            ? Scaffold(
                key: scaffoldKey,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: FloatingActionButton(
                  backgroundColor:
                      cubit.isEspConnected ? Colors.green : Colors.red,
                  onPressed: () {},
                  tooltip: cubit.espTime,
                  child: Icon(
                    Icons.electrical_services_outlined,
                    color: Colors.white,
                  ),
                ),
                drawer: Padding(
                  padding: const EdgeInsets.only(bottom: 75),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(200),
                    ),
                    child: SizedBox(
                      width: 280,
                      child: GestureDetector(
                        onTap: () {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                        },
                        child: Drawer(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              DrawerHeader(
                                decoration: BoxDecoration(
                                  color: customGreen,
                                ),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.6),
                                        child: Transform(
                                          alignment: Alignment.center,
                                          transform: Matrix4.rotationY(math.pi),
                                          child: Image.asset(
                                            'images/birdlogo.png',
                                            width: 90,
                                          ),
                                        ),
                                      )
                                    ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ExpansionPanelList(
                                  expandedHeaderPadding: EdgeInsets.all(0),
                                  expansionCallback:
                                      (int index, bool isExpanded) {
                                    if (index == 0) {
                                      cubit.mainDrawerValuesListBool = false;
                                      cubit.mainDrawerFarmsListList();
                                    } else {
                                      cubit.mainDrawerFarmsListBool = false;
                                      cubit.mainDrawerValuesList();
                                    }
                                  },
                                  children: <ExpansionPanel>[
                                    ExpansionPanel(
                                      headerBuilder: (BuildContext context,
                                          bool isExpanded) {
                                        return ListTile(
                                          tileColor: Colors.white,
                                          horizontalTitleGap: 0,
                                          title: Text("Multiple Farms"),
                                        );
                                      },
                                      body: SizedBox(
                                        height:
                                            cubit.usersCount == 1 ? 120 : 200,
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ListView.builder(
                                                  itemBuilder:
                                                      (context, index) {
                                                    return ListTile(
                                                      title: Text(
                                                        "Farm ${index + 1}",
                                                        style: TextStyle(
                                                          color: cubit.uId.split(
                                                                      '_')[1] ==
                                                                  '${index + 1}'
                                                              ? customViolet
                                                              : customGreen,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        cubit.virtualLogOutThenIn(
                                                            context,
                                                            cubit.uId.split(
                                                                    '_')[0] +
                                                                '_${index + 1}');
                                                      },
                                                    );
                                                  },
                                                  itemCount: cubit.usersCount),
                                            ),
                                            TextButton(
                                              onPressed: () {},
                                              onLongPress: () {
                                                cubit.addFarmDevise();
                                              },
                                              child: Text("Add Farm",
                                                  style: TextStyle(
                                                      color: customGreen,
                                                      fontSize: 17)),
                                              style: ButtonStyle(
                                                  padding: MaterialStateProperty
                                                      .all<EdgeInsets>(
                                                          EdgeInsets.all(15)),
                                                  foregroundColor:
                                                      MaterialStateProperty.all<Color>(
                                                          customGreen),
                                                  shape: MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(18.0),
                                                          side: BorderSide(color: customGreen)))),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            )
                                          ],
                                        ),
                                      ),
                                      isExpanded: cubit.mainDrawerFarmsListBool,
                                    ),
                                    ExpansionPanel(
                                      headerBuilder: (BuildContext context,
                                          bool isExpanded) {
                                        return ListTile(
                                          title: Text("Values range"),
                                        );
                                      },
                                      body: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Form(
                                          key: formKey,
                                          child: SizedBox(
                                            height: 150,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                            controller: cubit
                                                                .minTempController,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            inputFormatters: <
                                                                TextInputFormatter>[
                                                              // ignore: deprecated_member_use
                                                              WhitelistingTextInputFormatter
                                                                  // ignore: deprecated_member_use
                                                                  .digitsOnly
                                                            ],
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return 'this field cannot be empty';
                                                              } else {
                                                                return null;
                                                              }
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                              labelText:
                                                                  "min temp",
                                                            )),
                                                      ),
                                                      SizedBox(
                                                        width: 25,
                                                      ),
                                                      Expanded(
                                                        child: TextFormField(
                                                            controller: cubit
                                                                .maxTempController,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            inputFormatters: <
                                                                TextInputFormatter>[
                                                              // ignore: deprecated_member_use
                                                              WhitelistingTextInputFormatter
                                                                  // ignore: deprecated_member_use
                                                                  .digitsOnly
                                                            ],
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return 'this field cannot be empty';
                                                              } else {
                                                                return null;
                                                              }
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                              labelText:
                                                                  "max temp",
                                                            )),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                            controller: cubit
                                                                .minVentController,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            inputFormatters: <
                                                                TextInputFormatter>[
                                                              // ignore: deprecated_member_use
                                                              WhitelistingTextInputFormatter
                                                                  // ignore: deprecated_member_use
                                                                  .digitsOnly
                                                            ],
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return 'this field cannot be empty';
                                                              } else {
                                                                return null;
                                                              }
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                              labelText:
                                                                  "min vent",
                                                            )),
                                                      ),
                                                      SizedBox(
                                                        width: 25,
                                                      ),
                                                      Expanded(
                                                        child: TextFormField(
                                                            controller: cubit
                                                                .maxVentController,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            inputFormatters: <
                                                                TextInputFormatter>[
                                                              // ignore: deprecated_member_use
                                                              WhitelistingTextInputFormatter
                                                                  // ignore: deprecated_member_use
                                                                  .digitsOnly
                                                            ],
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return 'this field cannot be empty';
                                                              } else {
                                                                return null;
                                                              }
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                              labelText:
                                                                  "max vent",
                                                            )),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                            controller: cubit
                                                                .delayController,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            inputFormatters: <
                                                                TextInputFormatter>[
                                                              // ignore: deprecated_member_use
                                                              WhitelistingTextInputFormatter
                                                                  // ignore: deprecated_member_use
                                                                  .digitsOnly
                                                            ],
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return 'this field cannot be empty';
                                                              } else {
                                                                return null;
                                                              }
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                              hintText:
                                                                  "Delay in Minutes",
                                                              labelText:
                                                                  "Delay",
                                                            )),
                                                      ),
                                                      SizedBox(
                                                        width: 25,
                                                      ),
                                                      Expanded(
                                                        child: TextFormField(
                                                            controller: cubit
                                                                .historicalDelayController,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            inputFormatters: <
                                                                TextInputFormatter>[
                                                              // ignore: deprecated_member_use
                                                              WhitelistingTextInputFormatter
                                                                  // ignore: deprecated_member_use
                                                                  .digitsOnly
                                                            ],
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return 'this field cannot be empty';
                                                              } else {
                                                                return null;
                                                              }
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                              labelText:
                                                                  "backup data minutes",
                                                            )),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        if (formKey
                                                            .currentState!
                                                            .validate()) {
                                                          cubit
                                                              .sendValuesRanges();
                                                        }
                                                        // send data
                                                      },
                                                      child: Text('Send values',
                                                          style: TextStyle(
                                                              fontSize: 18.0,
                                                              color: Colors
                                                                  .white)),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: customViolet,
                                                        padding:
                                                            EdgeInsets.all(15),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10), // <-- Radius
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      isExpanded:
                                          cubit.mainDrawerValuesListBool,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  TextButton(
                                    onPressed: () {},
                                    onLongPress: () {
                                      if (cubit.isEspConnected) {
                                        cubit.sendResetEsp();
                                      } else {
                                        errorToast('No Device connected');
                                      }
                                    },
                                    child: Text("Reset",
                                        style: TextStyle(
                                            color: customViolet, fontSize: 17)),
                                    style: ButtonStyle(
                                        padding: MaterialStateProperty.all<
                                            EdgeInsets>(EdgeInsets.all(15)),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                customViolet),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                                side: BorderSide(
                                                    color: customViolet)))),
                                  ),
                                  TextButton(
                                      child: Text("Config",
                                          style: TextStyle(
                                              color: customViolet,
                                              fontSize: 17)),
                                      style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                              EdgeInsets>(EdgeInsets.all(15)),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  customViolet),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(18.0),
                                                  side: BorderSide(color: customViolet)))),
                                      onPressed: () {
                                        displayConfigDialog(context);
                                      }),
                                ],
                              ),
                              TextButton(
                                  onPressed: () {
                                    cubit.logOut(context);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "LOGOUT",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(
                                        Icons.logout,
                                        color: Colors.red,
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                appBar: AppBar(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  foregroundColor: Colors.white.withOpacity(0.7),
                  title: Text(
                    'FarmArt',
                    style: TextStyle(fontSize: 20),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: IconButton(
                          onPressed: () {
                            navigateAndPush(context, CardScreen());
                          },
                          icon: Icon(Icons.credit_card_outlined)),
                    )
                  ],
                  leading: InkWell(
                    onTap: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 5, top: 3, bottom: 5),
                        child: CircleAvatar(
                          radius: 12.0,
                          backgroundColor: Colors.white.withOpacity(0.6),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: Image.asset(
                              'images/birdlogo.png',
                              width: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: CurvedNavigationBar(
                    index: cubit.currentPage,
                    color: customGreen,
                    backgroundColor: Colors.white,
                    onTap: (index) {
                      cubit.changeCurrentScreen(index);
                    },
                    items: <Widget>[
                      Icon(
                        Icons.multiline_chart_sharp,
                        size: 30,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      Icon(Icons.bar_chart_rounded,
                          size: 30, color: Colors.white.withOpacity(0.7)),
                    ]),
                body: cubit.espTime == '::'
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wrong_location_outlined,
                              color: Colors.grey,
                              size: 100,
                            ),
                            Text(
                              'No Device Yet',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                  child: Text("Config",
                                      style: TextStyle(
                                          color: customViolet, fontSize: 17)),
                                  style: ButtonStyle(
                                      padding:
                                          MaterialStateProperty.all<EdgeInsets>(
                                              EdgeInsets.all(15)),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              customViolet),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                              side: BorderSide(
                                                  color: customViolet)))),
                                  onPressed: () {
                                    displayConfigDialog(context);
                                  }),
                            ),
                          ],
                        ),
                      )
                    : Stack(alignment: Alignment.topRight, children: [
                        activeScreen[cubit.currentPage],
                        Visibility(
                          visible: notificationData != null,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.red,
                              child: Center(
                                child: IconButton(
                                  iconSize: 30,
                                  color: Colors.white,
                                  onPressed: () {
                                    notificationFeedback(context, cubit);
                                  },
                                  icon: ShakeAnimatedWidget(
                                    enabled: true,
                                    duration: Duration(milliseconds: 1500),
                                    shakeAngle: Rotation.deg(z: 40),
                                    child: Icon(
                                      Icons.notifications_active_outlined,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
              )
            : Scaffold(
                appBar: AppBar(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  foregroundColor: Colors.white.withOpacity(0.7),
                  title: Text(
                    'FarmArt',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: FittedBox(
                    fit: BoxFit.cover,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 5, top: 3, bottom: 5),
                      child: CircleAvatar(
                        radius: 12.0,
                        backgroundColor: Colors.white.withOpacity(0.6),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: Image.asset(
                            'images/birdlogo.png',
                            width: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons
                            .signal_wifi_statusbar_connected_no_internet_4_outlined,
                        color: Colors.grey,
                        size: 100,
                      ),
                      Text(
                        'No internet',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                            child: Text("Config",
                                style: TextStyle(
                                    color: customViolet, fontSize: 17)),
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.all(15)),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        customViolet),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side:
                                            BorderSide(color: customViolet)))),
                            onPressed: () {
                              displayConfigDialog(context);
                            }),
                      ),
                    ],
                  ),
                ));
      },
    );
  }

  Future<void> displayConfigDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Choose configuration method'),
            content: SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Connectivity().checkConnectivity().then((value) {
                        if (value != ConnectivityResult.none) {
                          Navigator.pop(context);
                          navigateAndPush(context, ConfigurationScreen(true));
                        } else {
                          errorToast('check your internet');
                        }
                      });
                    },
                    child: Text("onLine",
                        style: TextStyle(color: Colors.green, fontSize: 17)),
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(15)),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.green)))),
                  ),
                  TextButton(
                      child: Text("offLine",
                          style: TextStyle(color: Colors.grey, fontSize: 17)),
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(15)),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.grey),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.grey)))),
                      onPressed: () {
                        Navigator.pop(context);
                        navigateAndPush(context, ConfigurationScreen(false));
                      }),
                ],
              ),
            ),
          );
        });
  }

  void notificationFeedback(BuildContext context, AppCubit cubit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(notificationData!['Title'] ?? "something unmoral happened"),
          content: Text(notificationData!['Body'] ?? "Check The dashboard"),
          actions: [
            OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Ok")),
          ],
        );
      },
    ).then((value) {
      notificationData = null;
      cubit.emit(ChangeDeviceStatus());
    });
  }
}
