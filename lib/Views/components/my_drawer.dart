import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_miner/utils/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDrawer extends StatefulWidget {
  final User user;
  MyDrawer({required this.user});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> userFormKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  String? name;
  String? password;
  bool isGoogle() {
    for (var data in widget.user.providerData) {
      if (data.providerId == "google.com") {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: Container(
                color: Color(0xffFABC3F),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DrawerHeader(
                              child: CircleAvatar(
                            radius: 50,
                            backgroundImage: (widget.user.isAnonymous)
                                ? null
                                : (widget.user.photoURL == null)
                                    ? null
                                    : NetworkImage(widget.user.photoURL!),
                          )),
                          Padding(
                            padding: const EdgeInsets.only(right: 50, top: 100),
                            child: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                )),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    (widget.user.isAnonymous)
                        ? Container()
                        : Text(
                            "Email : ${widget.user.email}",
                            style: TextStyle(color: Colors.white),
                          ),
                  ],
                ),
              )),
          Expanded(
              flex: 4,
              child: Container(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 40, top: 20),
                      child: Row(
                        children: [
                          (widget.user.isAnonymous)
                              ? Text("Anonymas User")
                              : (widget.user.displayName == null)
                                  ? Container(
                                      child: Row(
                                        children: [
                                          Text("UserName: "),
                                          Text((widget.user.isAnonymous)
                                              ? "No User"
                                              : "Unknown"),
                                        ],
                                      ),
                                    )
                                  : Text(
                                      "UserName: ${widget.user.displayName}",
                                      style: TextStyle(fontSize: 13),
                                    ),
                          IconButton(
                              onPressed: () {
                                editUserName();
                              },
                              icon: Icon(Icons.edit))
                        ],
                      ),
                    ),
                    (widget.user.isAnonymous || isGoogle())
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(right: 110),
                            child: TextButton(
                                onPressed: () async {
                                  editPassword();
                                },
                                child: Text("Change Password")),
                          )
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void editPassword() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change Password"),
          content: Form(
            key: passwordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.visiblePassword,
                  controller: passwordController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Please Enter a Password";
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
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                passwordController.clear();
                Get.back();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (passwordFormKey.currentState!.validate()) {
                  passwordFormKey.currentState!.save();

                  Map<String, dynamic> isUpdate =
                      await AuthHelper.authHelper.updatePassword(password!);

                  if (isUpdate['val'] != null) {
                    Get.snackbar("Success", "Password updated successfully!",
                        backgroundColor: Colors.green);

                    Get.back();
                  } else if (isUpdate['error'] != null) {
                    Get.snackbar("Failed", "${isUpdate['error']}",
                        backgroundColor: Colors.red);
                  }

                  passwordController.clear();
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void editUserName() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change UserName"),
          content: Form(
            key: userFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.visiblePassword,
                  controller: nameController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Please Enter a UserName";
                    }
                    return null;
                  },
                  onSaved: (val) {
                    name = val;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter UserName Here",
                    labelText: "UserName",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.clear();
                Get.back();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (userFormKey.currentState!.validate()) {
                  userFormKey.currentState!.save();

                  User? user =
                      await AuthHelper.authHelper.updateUsername(name!);

                  if (user != null) {
                    setState(() {
                      name = user.displayName;
                    });
                    Get.snackbar("Success", "UserName updated successfully!",
                        backgroundColor: Colors.green);
                    Get.back();
                  } else {
                    Get.snackbar("Failed", "UserName updatation failed!",
                        backgroundColor: Colors.red);
                  }
                  nameController.clear();
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
