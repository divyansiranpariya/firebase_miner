import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX package

class SplaceScreen extends StatefulWidget {
  const SplaceScreen({super.key});

  @override
  State<SplaceScreen> createState() => _SplaceScreenState();
}

class _SplaceScreenState extends State<SplaceScreen> {
  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        if (FirebaseAuth.instance.currentUser != null) {
          Get.offAllNamed("/");
        } else {
          Get.offAllNamed("/Login_page");
        }
        timer.cancel();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                    "https://img.freepik.com/free-photo/top-view-education-day-concept-with-copy-space_23-2148779746.jpg?semt=ais_hybrid"))),
      ),
    );
  }
}
