import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_miner/utils/local_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Views/Screens/Home_Page.dart';
import 'Views/Screens/chat_page.dart';
import 'Views/Screens/login_Page.dart';
import 'Views/Screens/splace_screen.dart';
import 'controllers/themecontroller.dart';

@pragma('vm:entry-point')
Future<void> onBGFCM(RemoteMessage remoteMessage) async {
  log("========BACKGROUND NOTIFICATION=========");
  log("Title: ${remoteMessage.notification!.title}");
  log("Body: ${remoteMessage.notification!.body}");

  log("Custom Data: ${remoteMessage.data}");
  log("=================================");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) async {
    log("===FOREGROUND NOTIFICATION");
    log("TITLE: ${remoteMessage.notification!.title}");
    log("TITLE: ${remoteMessage.notification!.body}");

    log("CustomData : ${remoteMessage.data}");
    log("===================");

    await LocalNotificationHelper.localNotificationHelper
        .showSimpleNotification(
            title: remoteMessage.notification!.title!,
            description: remoteMessage.notification!.body!);
  });

  //background terminated
  FirebaseMessaging.onBackgroundMessage(onBGFCM);
  final ThemeController themeController = Get.put(ThemeController());
  runApp(GetMaterialApp(
    theme: themeController.isDarkTheme.value
        ? ThemeData.dark()
        : ThemeData.light(),
    debugShowCheckedModeBanner: false,
    initialRoute: '/Login_page',
    getPages: [
      GetPage(name: '/', page: () => HomePage()),
      GetPage(name: '/Login_page', page: () => LoginPage()),
      GetPage(name: '/Chat_page', page: () => ChatPage()),
      GetPage(name: '/Splace_screen', page: () => SplaceScreen())
    ],
  ));
}
