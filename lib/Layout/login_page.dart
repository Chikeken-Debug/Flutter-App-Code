import 'dart:math';

import 'package:bird_system/Layout/creat_account.dart';
import 'package:bird_system/cubit/app_cubit.dart';
import 'package:bird_system/cubit/states.dart';
import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: must_be_immutable
class LoginPage extends StatelessWidget {
  var emailController = TextEditingController();
  var passController = TextEditingController();
  var forgetEmailController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  LoginPage({Key? key}) : super(key: key);

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
            body: state is CheckUserStateLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
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
                          Form(
                              key: formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                      autofillHints: const [
                                        AutofillHints.email
                                      ],
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      )),
                                  Visibility(
                                    visible: state is UserSignInVerifyError,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Text(
                                        "Email not verified the verification email will be resent now",
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: state is UserVerifyLoading,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Text(
                                        "Email Sent Please confirm it and login again",
                                        style: TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                  CheckboxListTile(
                                      title: Text(
                                        "Remember me",
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      value: cubit.rememberMe,
                                      onChanged: (newValue) {
                                        cubit.rememberMeBoxClicked();
                                      },
                                      controlAffinity: ListTileControlAffinity
                                          .leading, //  <-- leading Checkbox
                                      contentPadding: EdgeInsets.all(0.0)),
                                  SizedBox(
                                    width: double.infinity,
                                    child: state is UserSignInLoading
                                        ? Center(
                                            child: CircularProgressIndicator())
                                        : ElevatedButton(
                                            onPressed: () {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                cubit.signIn(
                                                    context,
                                                    emailController.text,
                                                    passController.text);
                                              }
                                            },
                                            child: state is UserSignInLoading
                                                ? CircularProgressIndicator()
                                                : Text('Log In',
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        color: Colors.white)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: customGreen,
                                              padding: EdgeInsets.all(15),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10), // <-- Radius
                                              ),
                                            ),
                                          ),
                                  ),
                                  SizedBox(height: 5),
                                  Center(
                                    child: TextButton(
                                        child: Text(
                                          'Forgotten password ? ',
                                          style: TextStyle(
                                            color: customGreen,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onPressed: () {
                                          displayTextInputDialog(
                                              context, cubit);
                                        }),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          '  OR  ',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        navigateAndPush(
                                            context, CreateAccount());
                                      },
                                      child: Text('Create New Account',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: customViolet,
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

  Future<void> displayTextInputDialog(
      BuildContext context, AppCubit cubit) async {
    var formKey = GlobalKey<FormState>();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter the Email to sent password reset email please'),
            content: Form(
              key: formKey,
              child: SizedBox(
                height: 150,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: forgetEmailController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'password cannot be empty';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(hintText: "Email"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          cubit.forgetPassword(
                              context, forgetEmailController.text);
                        }
                      },
                      child: Text('Send Email',
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customViolet,
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // <-- Radius
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
