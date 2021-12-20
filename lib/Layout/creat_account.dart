import 'dart:math';

import 'package:bird_system/cubit/cubit.dart';
import 'package:bird_system/cubit/states.dart';
import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: must_be_immutable
class CreateAccount extends StatelessWidget {
  var emailController = TextEditingController();
  var passController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  CreateAccount({Key? key}) : super(key: key);

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
            body: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 3.5,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(pi),
                                child: Image.asset(
                                  "images/birdlogo.png",
                                  width: 70,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "FarmArt",
                                style: TextStyle(
                                  fontSize: 25,
                                  color: customViolet,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ]),
                      ),
                    ),
                    Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Email cannot be empty';
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  prefixIcon: Icon(Icons.person),
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
                                controller: passController,
                                obscureText: cubit.hidePassword,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'password cannot be empty';
                                  } else if (value.length < 6) {
                                    return "Weak Password";
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: "Password",
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
                              height: 20,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: state is UserSignUpLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : ElevatedButton(
                                      onPressed: () {
                                        if (formKey.currentState!.validate()) {
                                          cubit.signUp(
                                              context,
                                              emailController.text,
                                              passController.text);
                                        }
                                      },
                                      child: Text('Sign UP',
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
