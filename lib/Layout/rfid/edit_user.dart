import 'package:bird_system/cubit/cubit.dart';
import 'package:bird_system/cubit/states.dart';
import 'package:bird_system/reusable/reusable_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

// ignore: must_be_immutable
class EditUserScreen extends StatelessWidget {
  var formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  var phoneController = TextEditingController();
  var photoController = TextEditingController();
  var roleController = TextEditingController();

  String id;
  bool dataHere;
  bool hereBefore = false;

  EditUserScreen(this.id, this.dataHere, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (BuildContext context, AppStates state) {},
      builder: (BuildContext context, AppStates state) {
        AppCubit cubit = AppCubit.get(context);
        if ((dataHere && nameController.text.isEmpty) ||
            state is GetPersonDone && hereBefore) {
          hereBefore = false;
          nameController.text = cubit.userData['Name'];
          phoneController.text = cubit.userData['Phone'];
          roleController.text = cubit.userData['PersonRole'];
          photoController.text = cubit.userData['ImageLink'];
        }

        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
              ),
              foregroundColor: Colors.white,
              title: Text("Edit User"),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(15),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'ID : $id',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: customGrey,
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
                child: state is SendToEditLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.check,
                        size: 35,
                        color: Colors.white,
                      ),
                onPressed: () {
                  if (nameController.text.isEmpty) {
                    errorToast("name can't be empty");
                  } else {
                    Map data = {
                      'Name': nameController.text,
                      'ID': id,
                      'Phone': phoneController.text.isEmpty
                          ? "empty"
                          : phoneController.text,
                      'PersonRole': roleController.text.isEmpty
                          ? "empty"
                          : roleController.text,
                      'ImageLink': photoController.text.isEmpty
                          ? "empty"
                          : photoController.text.replaceAll("https://", "")
                    };
                    cubit.editEmployee(data, context);
                  }
                }),
            body: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Form(
                    key: formKey,
                    child: TypeAheadField(
                      suggestionsCallback: (pattern) async {
                        List<String> sug = [];
                        for (var i in cubit.employeesNamesList) {
                          if (i.toLowerCase().contains(pattern.toLowerCase())) {
                            sug.add(i);
                          }
                        }
                        return sug;
                      },
                      onSuggestionSelected: (suggestion) {
                        int userIndex = cubit.employeesNamesList
                            .indexOf(suggestion.toString());
                        print(userIndex + 1);
                        dataHere = true;
                        hereBefore = true;
                        nameController.text = suggestion.toString();
                        cubit.getEmployeeData(userIndex + 1, context,
                            edit: true);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion.toString()),
                          leading: Icon(Icons.assignment_ind_outlined),
                        );
                      },
                      textFieldConfiguration: TextFieldConfiguration(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: "Name",
                            prefixIcon: Icon(Icons.person),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: customGrey, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          )),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  state is GetPersonLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                  controller: roleController,
                                  decoration: InputDecoration(
                                    labelText: "person role",
                                    prefixIcon: Icon(Icons.build_circle),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: customGreen, width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                  controller: phoneController,
                                  decoration: InputDecoration(
                                    labelText: "person phone",
                                    prefixIcon: Icon(Icons.phone),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: customGreen, width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                  controller: photoController,
                                  decoration: InputDecoration(
                                    labelText: "person photo drive url",
                                    prefixIcon: Icon(Icons.photo),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: customGreen, width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  )),
                            ),
                          ],
                        )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
