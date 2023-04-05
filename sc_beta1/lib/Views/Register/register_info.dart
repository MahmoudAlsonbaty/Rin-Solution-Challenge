import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:sc_beta1/Overlays/overlays.dart';
import 'package:sc_beta1/Views/Register/register_done.dart';
import 'package:sc_beta1/auth/auth_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:sc_beta1/cloud_storage/firebase_cloud_storage.dart';

import '../../auth/auth_exception.dart';
import '../../cloud_storage/cloud_constants.dart';
import '../../constants/ui_consts.dart';
import 'dart:developer' as devtools show log;

import '../../main.dart';

class RegisterInfoScreen extends StatefulWidget {
  final String Email;
  const RegisterInfoScreen({super.key, required this.Email});

  @override
  State<RegisterInfoScreen> createState() => _RegisterInfoScreenState();
}

class _RegisterInfoScreenState extends State<RegisterInfoScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _genderController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _birthDateController;

  //Todo change keyboard types

  final List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  /* final Map<String, GlobalKey<FormState>> formKeys = {
    "firstName": GlobalKey<FormState>(),
    "lastName":GlobalKey<FormState>(),
    "gender":GlobalKey<FormState>(),
    "password":GlobalKey<FormState>(),
    "confirmPassword":GlobalKey<FormState>(),
    "birthDate"GlobalKey<FormState>(),
  }; */
  //0 firstName, 1 LastName, 2 genderDropDown,3 genderWritten, 4 password, 5 confirmPassword, 6 DateOfBirth
  String _selectedGenderDropDownValue = "";
  bool _showGenderField = false;

  DateTime? _pickedDateValue;

  late AnimationController _genderAnimationController;
  late Animation<double> _genderAnimationVal;
  final String _requiredFieldError = "*Required";
  final String _shortPasswordError = "*password must be at least 6 characters";
  final Duration _genderAnimationDuration = const Duration(milliseconds: 500);

  @override
  void initState() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _genderController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _birthDateController = TextEditingController();

    _genderAnimationController =
        AnimationController(vsync: this, duration: _genderAnimationDuration);

    _genderAnimationVal = CurvedAnimation(
        parent: _genderAnimationController, curve: Curves.easeIn);

    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: ElevatedButton(
          onPressed: () {
            nextPressed();
          },
          style: ElevatedButton.styleFrom(
              elevation: 10,
              backgroundColor: registerLoginButtonColor,
              shape: const StadiumBorder(),
              side: const BorderSide(width: 1)),
          child: const Text("Next",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )),
        ),
        appBar: AppBar(
          backgroundColor: messageBackgroundColor,
          elevation: 5,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            "Register",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const MainScreen()),
                      (route) => false);
                  devtools.log("Pressed Home");
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: registerLoginButtonColor,
                    shape: const StadiumBorder(),
                    side: BorderSide(width: 1)),
                child: const Text("Home",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    )),
              ),
            )
          ],
        ),
        body: Container(
          constraints: BoxConstraints(
              minHeight: double.infinity, minWidth: double.infinity),
          decoration: const BoxDecoration(
            gradient: backgroundGradient,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 25, left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //!First and Last Name
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //!First Name
                      Form(
                        key: formKeys[0],
                        child: Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              formKeys[0].currentState!.validate();
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp("[0-9]"))
                            ],
                            validator: (String? text) {
                              if (text == null || text.isEmpty) {
                                return _requiredFieldError;
                              } else {
                                return null;
                              }
                            },
                            onFieldSubmitted: (value) {},
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(left: 15),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelText: "*First Name",
                                //isDense: true,
                                hintText: "Display Name",
                                //suffixIcon: Text("*"),
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w300),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                )),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(left: 10)),
                      //! Last Name
                      Form(
                        key: formKeys[1],
                        child: Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              formKeys[1].currentState!.validate();
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp("[0-9]"))
                            ],
                            onFieldSubmitted: (value) {},
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(left: 15),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelText: "Last Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 25)),

                  //!Gender
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //!DropDownMenu
                      Expanded(
                        child: Form(
                          key: formKeys[2],
                          child: DropdownButtonFormField(
                            value: "Select",
                            validator: (value) {
                              formKeys[3]
                                  .currentState!
                                  .validate(); //Validates the gender text field
                              if (value == "Select") {
                                return _requiredFieldError;
                              } else if (value == "other") {
                                setState(() {
                                  _genderAnimationController.forward();
                                  _showGenderField = true;
                                });
                              } else {
                                setState(() {
                                  _genderAnimationController.reverse();
                                  _showGenderField = false;
                                });
                              }
                              return null;
                            },
                            items: gendersList,
                            onChanged: (value) {
                              _selectedGenderDropDownValue = value;
                              formKeys[2].currentState!.validate();
                            },
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(left: 15),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelText: "*Gender",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                )),
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(left: 10)),
                      AnimatedContainer(
                        duration: _genderAnimationDuration,
                        width: _showGenderField
                            ? () {
                                try {
                                  return (formKeys[1]
                                          .currentContext!
                                          .findRenderObject() as RenderBox)
                                      .size
                                      .width;
                                } catch (_) {
                                  return 150.0; //this value will be user if it can't find the last name field size
                                }
                              }()
                            : 0,
                        child: FadeTransition(
                          opacity: _genderAnimationVal,
                          child: Form(
                            key: formKeys[3],
                            child: TextFormField(
                                controller: _genderController,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  formKeys[3].currentState!.validate();
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp("[0-9]"))
                                ],
                                validator: (String? text) {
                                  if (_selectedGenderDropDownValue != "other") {
                                    return null;
                                  }
                                  if (text == null || text.isEmpty) {
                                    return _requiredFieldError;
                                  } else {
                                    return null;
                                  }
                                },
                                onFieldSubmitted: (value) {},
                                decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.only(left: 15),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    labelText: "*Gender",
                                    hintText: "",
                                    hintStyle: const TextStyle(
                                        fontWeight: FontWeight.w300),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50.0),
                                    ))),
                          ),
                        ),
                      ),
                    ],
                  ),

                  //!Password
                  const Padding(padding: EdgeInsets.only(top: 25)),
                  Form(
                    key: formKeys[4],
                    child: TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.emailAddress,
                      obscureText: true,
                      validator: (String? text) {
                        if (text == null || text.isEmpty) {
                          return _requiredFieldError;
                        } else if (text.length < 6) {
                          return _shortPasswordError;
                        } else {
                          return null;
                        }
                      },
                      onFieldSubmitted: (value) {
                        formKeys[4].currentState!.validate();
                      },
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 15),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "*Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          )),
                    ),
                  ),
                  //!ConfirmPassword
                  const Padding(padding: EdgeInsets.only(top: 25)),
                  Form(
                    key: formKeys[5],
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        formKeys[5].currentState!.validate();
                      },
                      obscureText: true,
                      validator: (String? text) {
                        if (text == null || text.isEmpty) {
                          return _requiredFieldError;
                        } else if (text != _passwordController.text) {
                          return "Passwords don't match";
                        } else {
                          return null;
                        }
                      },
                      onFieldSubmitted: (value) {
                        formKeys[5].currentState!.validate();
                      },
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 15),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "*Confirm Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          )),
                    ),
                  ),

                  //!DateOfBirth
                  const Padding(padding: EdgeInsets.only(top: 25)),
                  Form(
                    key: formKeys[6],
                    child: TextFormField(
                      controller: _birthDateController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        formKeys[6].currentState!.validate();
                      },
                      readOnly: true,
                      onTap: () async {
                        _pickedDateValue = await showDatePicker(
                            context: context,
                            initialDate: (DateTime.utc(2002, 10)),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now()
                                .subtract(const Duration(days: 365 * 6)));

                        if (_pickedDateValue != null) {
                          devtools.log(_pickedDateValue
                              .toString()); //2023-03-23 00:00:00.000
                          setState(() {
                            _birthDateController.text =
                                "${_pickedDateValue!.year} - ${_pickedDateValue!.month} - ${_pickedDateValue!.day}";
                          });
                        } else {}
                      },
                      validator: (String? text) {
                        if (text == null || text.isEmpty) {
                          return _requiredFieldError;
                          //check if user choose an invalid birth date
                        } else if (_pickedDateValue!.compareTo(DateTime.now()) >
                            0) {
                          return "Invalid Date";
                        } else {
                          return null;
                        }
                      },
                      onFieldSubmitted: (value) {},
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 15),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "*Date of birth",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          suffixIcon: const Icon(Icons.calendar_month)),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            WhyDoWeNeedThisPressed(context);
                          },
                          child: Text(
                            "Why do we need this?",
                            style: TextStyle(
                                fontSize: 15,
                                color: aiTextMinimalColor,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void WhyDoWeNeedThisPressed(BuildContext context) {
    OverLayScreen().show(
        context: context,
        display: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Text(
                  "First & Last name:\n\tThey are used as displays\n\nGender & Date of birth:\n\tIt has been proven through a lot of research that there is a corelation between them and certain disorders",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textHeaderColor,
                  )),
              ElevatedButton(
                onPressed: () {
                  OverLayScreen().hide();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: registerLoginButtonColor,
                    shape: const StadiumBorder(),
                    side: BorderSide(width: 1)),
                child: const Text("OK",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    )),
              ),
            ],
          ),
        ));
  }

  List<DropdownMenuItem> gendersList = const [
    DropdownMenuItem(value: "Select", child: Text("Select")),
    DropdownMenuItem(value: "male", child: Text("Male")),
    DropdownMenuItem(value: "female", child: Text("Female")),
    DropdownMenuItem(value: "other", child: Text("Other"))
  ];
  Future<void> nextPressed() async {
    OverLayScreen().showLoading(context: context, text: "Loading...");

    //!Validate data

    //formKeys = 0 firstName, 1 LastName, 2 genderDropDown,3 genderWritten, 4 password, 5 confirmPassword, 6 DateOfBirth
    Map<String, dynamic> inputData = {};
    //*Validate First Name and Last Name(if exists)
    if (formKeys[0].currentState!.validate()) {
      inputData[firstNameField] = _firstNameController.text;

      //Since last name doesn't have a validator function we can just assign it as it is
      inputData[lastNameField] = _lastNameController.text;
    }

    //*Validate gender menu and field if "other" is selected
    if (formKeys[2].currentState!.validate()) {
      //checks if the user selected the "other" option
      if (_selectedGenderDropDownValue == "other") {
        //check if it's filled correctly, otherwise do nothing
        if (formKeys[3].currentState!.validate()) {
          inputData[genderField] = _genderController.text;
        }
      } else {
        //the user selected either male or female
        inputData[genderField] = _selectedGenderDropDownValue;
      }
    }

    //*Validate passwords
    if (formKeys[4].currentState!.validate() &&
        formKeys[5].currentState!.validate()) {
      inputData["password"] = _passwordController.text;
    }

    //*Validate Date of birth
    if (formKeys[6].currentState!.validate()) {
      inputData[birthDateField] = _pickedDateValue;
    }
    //Todo remove this
    inputData.forEach(
      (key, value) {
        devtools.log("input Data, $key : $value as ${value.runtimeType}");
      },
    );

    //if there is data missing Ex: a field failed Validation
    if (inputData.length < 5) {
      OverLayScreen().hide();
      return;
    }

    //*This will run if all tests passed

    //First Logout user if signed in
    try {
      if (AuthService.Firebase().currentUser != null) {
        await AuthService.Firebase().logOut();
      }
      //login again (important for password update)
      final user = await AuthService.Firebase()
          .logIn(email: widget.Email, password: "dummyPasswordData");

      //*set new password

      if (!await AuthService.Firebase()
          .setPassword(password: inputData["password"])) {
        //this will run if the set password failed
        throw CouldNotRegisterUserException;
      }

      //*upload user data
      await CloudStorage(user: user).updateCreateInfo(
        firstName: inputData[firstNameField],
        lastName: inputData[lastNameField],
        birthDate: inputData[birthDateField],
        gender: inputData[genderField],
      );
      await AuthService.Firebase().logOut();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const RegisterDoneScreen()),
          (route) => false);
      OverLayScreen().hide();
    } catch (e) {
      //Hides the Loading Overlay
      OverLayScreen().hide();
      //Shows the ErrorOverlay
      OverLayScreen().show(
          context: context,
          display: Column(
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
                size: MediaQuery.of(context).size.width / 4,
              ),
              Text(
                "Something went wrong \n Error: $e ",
                textAlign: TextAlign.center,
              ),
              TextButton(
                  onPressed: () {
                    OverLayScreen().hide();
                  },
                  child: const Text("Ok"))
            ],
          ));
    }
  }
}
