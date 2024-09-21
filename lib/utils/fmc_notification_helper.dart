import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

import 'package:googleapis_auth/auth_io.dart';

class FCMNotificationHelper {
  FCMNotificationHelper._();
  static final FCMNotificationHelper fCMNotificationHelper =
      FCMNotificationHelper._();

  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  //fetch FMC registeration token

  Future<String> fetchFMCToken() async {
    String? token = await firebaseMessaging.getToken();

    log("======================");
    log("FCM TOKEN:$token");
    log("======================");
    return token!;
  }

  Future<String> getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(
      await rootBundle.loadString(
          'assets/fir-miner-4444a-firebase-adminsdk-riofi-b5723e288a.json'),
    );
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final authClient =
        await clientViaServiceAccount(accountCredentials, scopes);
    return authClient.credentials.accessToken.data;
  }

  Future<void> sendFCM(
      {required String msg,
      required String senderEmail,
      required String token}) async {
    // String? token =
    //     await FCMNotificationHelper.fCMNotificationHelper.fetchFMCToken();
    final String accessToken = await getAccessToken();
    final String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/fir-miner-4444a/messages:send';
    final Map<String, dynamic> myBody = {
      'message': {
        'token': token,
        'notification': {
          'title': msg,
          'body': senderEmail,
        },
        'data': {
          'age': "22",
          'school': 'PQR',
        }
      },
    };
    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(myBody),
    );
    if (response.statusCode == 200) {
      print('-------------------');
      print('Notification sent successfully');
      print('-------------------');
    } else {
      print('-------------------');
      print('Failed to send notification:${response.body}');
      print('-------------------');
    }
  }
}
