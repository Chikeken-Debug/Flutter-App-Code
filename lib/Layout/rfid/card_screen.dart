import 'package:bird_system/Layout/rfid/edit_user.dart';
import 'package:bird_system/cubit/cubit.dart';
import 'package:bird_system/cubit/states.dart';
import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math; // import this

// ignore: must_be_immutable
class CardScreen extends StatelessWidget {
  const CardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {},
        builder: (BuildContext context, AppStates state) {
          AppCubit cubit = AppCubit.get(context);

          if (cubit.employeesNamesList.isEmpty &&
              cubit.thereEmployee &&
              state is! GetEmployeeNamesLoading) {
            cubit.getEmployeeNames();
          }
          return Scaffold(
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
                  padding: const EdgeInsets.only(left: 5, top: 3, bottom: 5),
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
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(children: [
                cubit.currentUserId == "NULL"
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            padding: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                                border: Border.all(color: customGreen),
                                borderRadius: BorderRadius.circular(20)),
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.label_off,
                                  color: Colors.grey,
                                  size: 80,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "No ID yet",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                )
                              ],
                            )),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          child: cubit.currentUserState != "notfound"
                              ? Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.orange),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        child: Text(
                                          'Last Scan',
                                          style: TextStyle(
                                              color: customGrey,
                                              fontSize: 35,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: Text(
                                                        cubit.currentUserName,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.orange,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                        'ID : ${cubit.currentUserId}'),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    cubit.currentUserState ==
                                                            "new"
                                                        ? Wrap(
                                                            crossAxisAlignment:
                                                                WrapCrossAlignment
                                                                    .center,
                                                            children: const [
                                                              Text(
                                                                'not Registered ',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .error_outline,
                                                                color:
                                                                    Colors.red,
                                                              )
                                                            ],
                                                          )
                                                        : Wrap(
                                                            children: const [
                                                              Text(
                                                                'Process completed',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                              ),
                                                              Center(
                                                                child: Icon(
                                                                  Icons.check,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                  ]),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: customGreen,
                                                ),
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: FadeInImage
                                                          .assetNetwork(
                                                        height: 120,
                                                        placeholder:
                                                            'images/vector.png',
                                                        imageErrorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return SizedBox(
                                                            height: 120,
                                                            child: Center(
                                                              child: Image.asset(
                                                                  'images/vector.png'),
                                                            ),
                                                          );
                                                        },
                                                        image: cubit
                                                            .currentUserImageUrl,
                                                      ),
                                                    )),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.orange),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        child: Text(
                                          'Last Scan',
                                          style: TextStyle(
                                              color: customGrey,
                                              fontSize: 35,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: Text(
                                                        'User doesn\'t exist',
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      'ID : ${cubit.currentUserId}',
                                                      style: TextStyle(
                                                          color: customGrey,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15.0),
                                                      child: Center(
                                                        child: TextButton(
                                                            child: Text("AddUser",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        17)),
                                                            style: ButtonStyle(
                                                                padding: MaterialStateProperty.all<EdgeInsets>(
                                                                    EdgeInsets.all(
                                                                        15)),
                                                                foregroundColor:
                                                                    MaterialStateProperty.all<Color>(Colors
                                                                        .grey),
                                                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(18.0),
                                                                    side: BorderSide(color: Colors.grey)))),
                                                            onPressed: () {
                                                              navigateAndPush(
                                                                  context,
                                                                  EditUserScreen(
                                                                      cubit
                                                                          .currentUserId,
                                                                      false));
                                                            }),
                                                      ),
                                                    ),
                                                  ]),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: customGreen,
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      child: SizedBox(
                                                        height: 120,
                                                        child: Center(
                                                          child: Image.asset(
                                                              'images/vector.png'),
                                                        ),
                                                      )),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                        ),
                      ),
                Expanded(
                  child: cubit.employeesNamesList.isEmpty && cubit.thereEmployee
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(15),
                          child: cubit.employeesNamesList.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.not_accessible_rounded,
                                        color: Colors.grey,
                                        size: 80,
                                      ),
                                      Text(
                                        'No Groups',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      )
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: cubit.employeesNamesList.length,
                                  itemBuilder: (context, index) {
                                    return groupItemBuilder(
                                        index, context, cubit, state);
                                  },
                                  separatorBuilder: (context, index) {
                                    return SizedBox(
                                      height: 10,
                                    );
                                  }),
                        ),
                ),
              ]),
            ),
          );
        });
  }

  Widget groupItemBuilder(
      int index, BuildContext context, AppCubit cubit, state) {
    return (state is GetPersonLoading && index + 1 == cubit.activeUser)
        ? Center(
            child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: CupertinoActivityIndicator(
              radius: 15,
            ),
          ))
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(115, 115, 115, 1.0),
            ),
            child: InkWell(
              onTap: () {
                cubit.getEmployeeData(index + 1, context);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: customGreen,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      index < 9 ? '0${index + 1}' : '${index + 1}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        cubit.employeesNamesList[index].trim(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
