import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationHelper {
  LocalNotificationHelper._();
  static final LocalNotificationHelper localNotificationHelper =
      LocalNotificationHelper._();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initLocalNotifications() async {
    AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("mipmap/ic_launcher");
    DarwinInitializationSettings IOSInitializationSettings =
        DarwinInitializationSettings();

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: IOSInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  //show simple notifications
  Future<void> showSimpleNotification(
      {required String title, required String description}) async {
    await initLocalNotifications();

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "SN",
      "Simple Notification",
      priority: Priority.max,
      importance: Importance.max,
      styleInformation: BigPictureStyleInformation(
          DrawableResourceAndroidBitmap("mipmap/ic_launcher")),
    );
    DarwinNotificationDetails IOSNotificationDetails =
        const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: IOSNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      1,
      title,
      description,
      notificationDetails,
    );
  }

  //show big image notification
  Future<void> showBigImageNotification(
      {required String title, required String description}) async {
    await initLocalNotifications();

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "SN",
      "Simple Notification",
      priority: Priority.max,
      importance: Importance.max,
    );
    DarwinNotificationDetails IOSNotificationDetails =
        const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: IOSNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      1,
      title,
      description,
      notificationDetails,
    );
  }

  Future<void> showMadiaStyleNotification(
      {required String title, required String description}) async {
    await initLocalNotifications();

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "SN",
      "Simple Notification",
      priority: Priority.max,
      importance: Importance.max,
      styleInformation: MediaStyleInformation(),
    );
    DarwinNotificationDetails IOSNotificationDetails =
        const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: IOSNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      1,
      title,
      description,
      notificationDetails,
    );
  }
}
