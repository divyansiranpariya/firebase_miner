import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_miner/model/student_model.dart';
import 'package:firebase_miner/utils/auth_helper.dart';
import 'package:firebase_miner/utils/firestore_helper.dart';
import 'package:firebase_miner/utils/fmc_notification_helper.dart';
import 'package:firebase_miner/utils/local_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../controllers/themecontroller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  AppLifecycleState? _appLifecycleState;
  final ThemeController themeController = Get.find();
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? email;
  int? id;
  int? age;
  String? name;
  String? password;
  String title = "Simple Notofication";
  String description = "Dummy data";

  Future<void> getFCMToken() async {
    FCMNotificationHelper.fCMNotificationHelper.fetchFMCToken();
  }

  Future<void> requestPermission() async {
    PermissionStatus notificationPermissionStatus =
        await Permission.notification.request();
    log("=================");
    log("${notificationPermissionStatus}");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFCMToken();
    requestPermission();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        print("$state");
        break;
      case AppLifecycleState.resumed:
        print("$state");
        break;
      case AppLifecycleState.detached:
        print("$state");
        break;

      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // IconButton(
                    //     onPressed: () {
                    //       themeController.toggleTheme();
                    //     },
                    //     icon: Icon(Icons.sunny)),
                    PopupMenuButton<String>(
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            onTap: () async {
                              await LocalNotificationHelper
                                  .localNotificationHelper
                                  .showSimpleNotification(
                                      title: title, description: description);
                            },
                            value: 'Simple Notification',
                            child: Text('Simple Notification'),
                          ),
                          PopupMenuItem<String>(
                            onTap: () async {
                              await LocalNotificationHelper
                                  .localNotificationHelper
                                  .showBigImageNotification(
                                      title: title, description: description);
                            },
                            value: 'BigImage Notification',
                            child: Text('BigImage Notification'),
                          ),
                          PopupMenuItem<String>(
                            onTap: () async {
                              await LocalNotificationHelper
                                  .localNotificationHelper
                                  .showMadiaStyleNotification(
                                      title: title, description: description);
                            },
                            value: 'MediaStyle Notification',
                            child: Text('MediaStyle Notification'),
                          ),
                        ];
                      },
                    ),
                  ],
                )),
            Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(
                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQsjFiErwqO1LRUCqtju2Rozsb5Gga9A_siynnvCsnv4BWJYf40GxP1X98DGqJFAtjGrTI&usqp=CAU"))),
                )),
            Expanded(
                flex: 4,
                child: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          "Hello",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 30),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Welcome To Little app",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        SizedBox(
                          width: 200,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(),
                            onPressed: () async {
                              Map<String, dynamic> res = await AuthHelper
                                  .authHelper
                                  .signInAsGuestUser();
                              if (res['user'] != null) {
                                Get.snackbar(
                                    "Success", "Sign In Successfully...",
                                    backgroundColor: Colors.green);

                                Get.toNamed('/', arguments: res['user']);
                              } else {
                                Get.snackbar("Failed", "Sign In Failed...",
                                    backgroundColor: Colors.red);
                              }
                            },
                            child: Text(
                              "Login",
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: 200,
                          child: OutlinedButton(
                            onPressed: () {
                              signInUser();
                            },
                            child: Text(
                              "Sign In",
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Dont't have an account ? ",
                              style: TextStyle(fontSize: 15),
                            ),
                            TextButton(
                                onPressed: () {
                                  signUpUser();
                                },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(color: Colors.purple),
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: 300,
                          child: OutlinedButton(
                              onPressed: () async {
                                Map<String, dynamic> res = await AuthHelper
                                    .authHelper
                                    .signInWithGoogle();

                                if (res['user'] != null) {
                                  Get.snackbar("Sucess", "Login sucessfully...",
                                      backgroundColor: Colors.green);
                                  User user = res['user'];

                                  // UserModel userModel = UserModel(
                                  //   email: user.email!,
                                  // );

                                  await FirestoreHelper.firestoreHelper
                                      .addAuthenticationUser(
                                    email: user.email!,
                                  );
                                  Get.toNamed(
                                    '/',
                                    arguments: res['user'],
                                  );
                                } else if (res['error'] != null) {
                                  Get.snackbar("Failed", "${res['error']}...",
                                      backgroundColor: Colors.green);
                                } else {
                                  Get.snackbar("Failed", "login failed",
                                      backgroundColor: Colors.red);
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Text("Login with google")],
                              )),
                        ),
                        // OutlinedButton(
                        //   onPressed: () async {
                        //     await FCMNotificationHelper.fCMNotificationHelper
                        //         .sendFCM(: "Hello", senderEmail: "Successful");
                        //   },
                        //   child: Text("notification"),
                        // ),
                      ],
                    ),
                  ),
                ))
          ],
        ));
  }

  signUpUser() {
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Sign Up"),
            content: Form(
              key: signUpFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Please Enter Email...";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      email = val;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter Email ",
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Please Enter Password";
                      } else if (val.length <= 6) {
                        return "Password must Contain 6 Letters";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      password = val;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter Password Here",
                      labelText: "Password",
                      prefixIcon: Icon(Icons.security),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  emailController.clear();
                  passwordController.clear();
                  idController.clear();
                  nameController.clear();
                  ageController.clear();
                  name = null;
                  id = null;
                  age = null;
                  email = null;
                  password = null;
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  if (signUpFormKey.currentState!.validate()) {
                    signUpFormKey.currentState!.save();
                    Map<String, dynamic> res = await AuthHelper.authHelper
                        .signUpUserWithEmailAndPassword(
                            email: email!, password: password!);
                    if (res['user'] != null) {
                      Get.snackbar("Success", "Sign Up Successfully...",
                          backgroundColor: Colors.green);
                      User user = res['user'];

                      await FirestoreHelper.firestoreHelper
                          .addAuthenticationUser(
                        email: email!,
                      );

                      Get.toNamed('/', arguments: res['user']);
                    } else {
                      Get.snackbar("Failed", "Sign Up Failed...",
                          backgroundColor: Colors.red);
                    }
                    emailController.clear();
                    passwordController.clear();
                    idController.clear();
                    nameController.clear();
                    ageController.clear();
                    name = null;
                    id = null;
                    age = null;
                    email = null;
                    password = null;
                    Get.back();
                  }
                },
                child: Text("Sign Up"),
              ),
            ],
          ),
        );
      },
    );
  }

  signInUser() {
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Sign In"),
            content: Form(
              key: signInFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Please Enter Email...";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      email = val;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter Email ",
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Please Enter Password";
                      } else if (val.length <= 6) {
                        return "Password must Contain 6 Letters";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      password = val;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter Password Here",
                      labelText: "Password",
                      prefixIcon: Icon(Icons.security),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  emailController.clear();
                  passwordController.clear();
                  idController.clear();
                  nameController.clear();
                  ageController.clear();
                  name = null;
                  id = null;
                  age = null;
                  email = null;
                  password = null;
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  if (signInFormKey.currentState!.validate()) {
                    signInFormKey.currentState!.save();
                    Map<String, dynamic> res = await AuthHelper.authHelper
                        .signInWithEmailAndPassword(
                            email: email!, password: password!);
                    if (res['user'] != null) {
                      Get.snackbar("Success", "Sign In Successfully...",
                          backgroundColor: Colors.green);
                      Get.toNamed('/', arguments: res['user']);
                    } else {
                      Get.snackbar("Failed", "Sign In Failed...",
                          backgroundColor: Colors.red);
                    }
                    emailController.clear();
                    passwordController.clear();
                    email = null;
                    password = null;
                    Get.back();
                  }
                },
                child: Text("Sign In"),
              ),
            ],
          ),
        );
      },
    );
  }
}
