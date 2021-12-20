import 'package:bird_system/cubit/cubit.dart';
import 'package:bird_system/cubit/states.dart';
import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: must_be_immutable
class ConfigurationScreen extends StatelessWidget {
  bool online;
  var wifiController = TextEditingController();
  var wifiPassController = TextEditingController();

  var emailController = TextEditingController();
  var emailPassController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  var formKey_2 = GlobalKey<FormState>();

  ConfigurationScreen(this.online, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (BuildContext context, AppStates state) {},
      builder: (BuildContext context, AppStates state) {
        AppCubit cubit = AppCubit.get(context);
        return SafeArea(
            child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Scaffold(
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
            ),
            body: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  children: [
                    Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height /
                            (cubit.sendNewUser && online ? 6 : 3.75),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Device configuration",
                                style: TextStyle(
                                  fontSize: 28,
                                  color: customViolet,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                            ]),
                      ),
                    ),
                    Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                              visible: !online,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  'First Connect to wifi ESP with password <88888888>',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.deepOrange),
                                ),
                              ),
                            ),
                            TextFormField(
                                controller: wifiController,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'wifi name cannot be empty';
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: "wifi name",
                                  prefixIcon: Icon(Icons.wifi),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: customGreen, width: 2.0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                )),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                                controller: wifiPassController,
                                obscureText: cubit.hidePassword,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'password cannot be empty';
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: "WIFI Password",
                                  prefixIcon: Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(cubit.hidePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      cubit.changePassShowClicked();
                                    },
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: customGreen, width: 2.0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                )),
                            SizedBox(
                              height: 10,
                            ),
                            online
                                ? CheckboxListTile(
                                    title: Text(
                                      "Send NEW user",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    value: cubit.sendNewUser,
                                    onChanged: (newValue) {
                                      cubit.sendNewUserCheckBox();
                                    },
                                    controlAffinity: ListTileControlAffinity
                                        .leading, //  <-- leading Checkbox
                                    contentPadding: EdgeInsets.all(0.0))
                                : Container(),
                            Visibility(
                              visible: cubit.sendNewUser,
                              child: Form(
                                  key: formKey_2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                            controller: emailController,
                                            keyboardType: TextInputType.text,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'wifi name cannot be empty';
                                              } else {
                                                return null;
                                              }
                                            },
                                            decoration: InputDecoration(
                                              labelText: "New user Email",
                                              prefixIcon: Icon(Icons.person),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: customGreen,
                                                    width: 2.0),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            )),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                            controller: emailPassController,
                                            obscureText: cubit.hidePassword,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'password cannot be empty';
                                              } else {
                                                return null;
                                              }
                                            },
                                            decoration: InputDecoration(
                                              labelText: "New User Password",
                                              prefixIcon: Icon(Icons.lock),
                                              suffixIcon: IconButton(
                                                icon: Icon(cubit.hidePassword
                                                    ? Icons.visibility
                                                    : Icons.visibility_off),
                                                onPressed: () {
                                                  cubit.changePassShowClicked();
                                                },
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: customGreen,
                                                    width: 2.0),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            )),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: state is SendConfigLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : ElevatedButton(
                                      onPressed: () {
                                        if (formKey.currentState!.validate()) {
                                          if (online) {
                                            if (cubit.sendNewUser) {
                                              if (formKey_2.currentState!
                                                  .validate()) {
                                                cubit.sendConfigOnline(
                                                  context,
                                                  wifiController.text,
                                                  wifiPassController.text,
                                                  nextId: emailController.text,
                                                  nextPass:
                                                      emailPassController.text,
                                                );
                                              }
                                            } else {
                                              cubit.sendConfigOnline(
                                                context,
                                                wifiController.text,
                                                wifiPassController.text,
                                              );
                                            }
                                          } else {
                                            cubit.sendToEsp(
                                                context,
                                                wifiController.text,
                                                wifiPassController.text);
                                          }
                                        }
                                      },
                                      child: Text('Send Data',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        primary: customGreen,
                                        padding: EdgeInsets.all(15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // <-- Radius
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ));
      },
    );
  }
}
// https://pub.dev/packages/wifi_info_flutter
