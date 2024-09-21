import 'dart:async';

import 'package:firebase_miner/utils/auth_helper.dart';
import 'package:firebase_miner/utils/fmc_notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../model/student_model.dart';

class FirestoreHelper {
  FirestoreHelper._();
  static final FirestoreHelper firestoreHelper = FirestoreHelper._();
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  //add authentication user
  addAuthenticationUser({required String email}) async {
    bool isUserExists = false;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("users").get();
    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
        querySnapshot.docs;

    allDocs.forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      Map<String, dynamic> docData = doc.data();
      if (docData['email'] == email) {
        isUserExists = true;
      }
    });

    if (isUserExists == false) {
      // await db.collection("users").add({"email": email});

      DocumentSnapshot<Map<String, dynamic>> qs =
          await db.collection("records").doc("users").get();
      Map<String, dynamic>? data = qs.data();
      int id = data!['id'];
      int counter = data['counter'];
      id++;

      String? token =
          await FCMNotificationHelper.fCMNotificationHelper.fetchFMCToken();

      await db.collection("users").doc("$id").set({
        "email": email,
        "token": token,
      });

      counter++;
      await db
          .collection("records")
          .doc("users")
          .update({"id": id, "counter": counter});
    }
  }

  //fetch user
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllUsers() {
    return db.collection("users").snapshots();
  }

  //delete user

  Future<void> deleteUser({required String docId}) async {
    await db.collection("users").doc(docId).delete();
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await db.collection("records").doc("users").get();
    int counter = userDoc.data()!['counter'];
    counter--;

    await db.collection("records").doc("users").update({"counter": counter});
  }

  //create a chatroom and store message

  sendMessage({required String msg, required String receiverEmail}) async {
    String senderEmail = AuthHelper.firebaseAuth.currentUser!.email!;
    bool isChatroomExists = false;

    //check if a chatroom is already exists or not

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms =
        querySnapshot.docs;

    String? chatroomId;

    allChatrooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      List users = chatroom.data()['users'];

      if (users.contains(receiverEmail) && users.contains(senderEmail)) {
        isChatroomExists = true;
        chatroomId = chatroom.id;
      }
      ;
    });

    if (isChatroomExists == false) {
      DocumentReference<Map<String, dynamic>> docRef =
          await db.collection("chatrooms").add({
        "users": [senderEmail, receiverEmail]
      });
      chatroomId = docRef.id;
    }
    //store a message
    await db
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .add({
      "msg": msg,
      "senderEmail": senderEmail,
      "receiverEmail": receiverEmail,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  //featch al messages

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> fetchAllMessages(
      {required String receverEmail}) async {
    String senderEmail = AuthHelper.firebaseAuth.currentUser!.email!;
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms =
        querySnapshot.docs;

    String? chatroomId;

    allChatrooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      List users = chatroom.data()['users'];

      if (users.contains(receverEmail) && users.contains(senderEmail)) {
        chatroomId = chatroom.id;
      }
      ;
    });

    return db
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();

    //where("msg",isEqualto:"hey")
  }

  //delete mesaages

  deleteMessage(
      {required String receiverEmail, required String messageDocId}) async {
    String senderEmail = AuthHelper.firebaseAuth.currentUser!.email!;
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms =
        querySnapshot.docs;

    String? chatroomId;

    allChatrooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      List users = chatroom.data()['users'];

      if (users.contains(receiverEmail) && users.contains(senderEmail)) {
        chatroomId = chatroom.id;
      }
      ;
    });

    await db
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .doc(messageDocId)
        .delete();
  }

  updateMessage(
      {required String msg,
      required String receiverEmail,
      required String messageDocId}) async {
    String senderEmail = AuthHelper.firebaseAuth.currentUser!.email!;
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms =
        querySnapshot.docs;

    String? chatroomId;

    allChatrooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      List users = chatroom.data()['users'];

      if (users.contains(receiverEmail) && users.contains(senderEmail)) {
        chatroomId = chatroom.id;
      }
      ;
    });

    await db
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .doc(messageDocId)
        .update({"msg": msg, "updatedTimeStamp": FieldValue.serverTimestamp()});
  }
}
