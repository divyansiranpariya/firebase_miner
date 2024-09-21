import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  var isDarkTheme = false.obs;

  void toggleTheme() {
    if (Get.isDarkMode) {
      Get.changeTheme(ThemeData.light());
      isDarkTheme(false);
    } else {
      Get.changeTheme(ThemeData.dark());
      isDarkTheme(true);
    }
  }
}
