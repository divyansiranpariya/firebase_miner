import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_miner/utils/auth_helper.dart';
import 'package:firebase_miner/utils/firestore_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../utils/fmc_notification_helper.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController chatControoler = TextEditingController();
  TextEditingController editingController = TextEditingController();
  bool ischange = false;
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> reciever =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xffFABC3F),
        leading: Container(),
        title: (reciever['email'] == AuthHelper.firebaseAuth.currentUser!.email)
            ? Column(
                children: [
                  Text(
                    "Chat Page",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "YourSelf",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ],
              )
            : Column(
                children: [
                  Text(
                    "ChatPage",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "${reciever['email']}",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ],
              ),
      ),
      body: Column(
        children: [
          Expanded(
              flex: 15,
              child: Container(
                child: FutureBuilder(
                  future: FirestoreHelper.firestoreHelper
                      .fetchAllMessages(receverEmail: reciever['email']),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text("ERROR: ${snapshot.error}"),
                      );
                    } else if (snapshot.hasData) {
                      Stream<QuerySnapshot<Map<String, dynamic>>>? dataStream =
                          snapshot.data;
                      return StreamBuilder(
                          stream: dataStream,
                          builder: (context, ss) {
                            if (ss.hasError) {
                              return Center(
                                child: Text("ERROR: ${ss.error}"),
                              );
                            } else if (ss.hasData) {
                              QuerySnapshot<Map<String, dynamic>>? data =
                                  ss.data;

                              List<QueryDocumentSnapshot<Map<String, dynamic>>>
                                  allMessages = (data == null) ? [] : data.docs;

                              return (allMessages.isEmpty)
                                  ? Center(
                                      child: Text("No Any chat yet..!!"),
                                    )
                                  : ListView.builder(
                                      reverse: true,
                                      itemCount: allMessages.length,
                                      itemBuilder: (context, i) {
                                        Timestamp timestamp =
                                            allMessages[i].data()['timestamp'];
                                        DateTime dateTime = timestamp.toDate();

                                        String formattedTime =
                                            DateFormat('hh:mm a')
                                                .format(dateTime);

                                        return Row(
                                          mainAxisAlignment:
                                              (reciever['email'] !=
                                                      allMessages[i].data()[
                                                          'receiverEmail'])
                                                  ? MainAxisAlignment.start
                                                  : MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  bottom: 10),
                                              child:
                                                  (reciever['email'] !=
                                                          allMessages[i].data()[
                                                              'receiverEmail'])
                                                      ? Container(
                                                          color: Colors.pink,
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                  "${allMessages[i].data()['msg']}"),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    formattedTime,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            10),
                                                                  ),
                                                                ],
                                                              ), // Display formatted time
                                                            ],
                                                          ),
                                                        )
                                                      : PopupMenuButton<String>(
                                                          onSelected: (String
                                                              val) async {
                                                            if (val ==
                                                                "delete") {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          "Are you sure you want to delete this message?"),
                                                                      content:
                                                                          Row(
                                                                        children: [
                                                                          TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: Text("Cancle")),
                                                                          TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                                FirestoreHelper.firestoreHelper.deleteMessage(receiverEmail: reciever['email'], messageDocId: allMessages[i].id);
                                                                              },
                                                                              child: Text("Delete")),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  });
                                                            }
                                                            if (val == "edit") {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        "Update Message"),
                                                                    content:
                                                                        SizedBox(
                                                                      height:
                                                                          50,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                TextField(
                                                                              controller: editingController,
                                                                              decoration: InputDecoration(
                                                                                border: OutlineInputBorder(),
                                                                                hintText: "Edit Message",
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    actions: [
                                                                      TextButton(
                                                                        child: Text(
                                                                            'Cancel'),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                          editingController
                                                                              .clear();
                                                                        },
                                                                      ),
                                                                      TextButton(
                                                                        child: Text(
                                                                            'Update'),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                          FirestoreHelper.firestoreHelper.updateMessage(
                                                                              msg: editingController.text,
                                                                              receiverEmail: reciever['email'],
                                                                              messageDocId: allMessages[i].id);
                                                                          editingController
                                                                              .clear();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            }
                                                          },
                                                          itemBuilder:
                                                              (context) => [
                                                            const PopupMenuItem(
                                                              value: 'delete',
                                                              child: Text(
                                                                  'Delete'),
                                                            ),
                                                            const PopupMenuItem(
                                                              value: 'edit',
                                                              child:
                                                                  Text('Edit'),
                                                            ),
                                                          ],
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    Colors.pink,
                                                                borderRadius: (allMessages[i]
                                                                            .data()[
                                                                        ''])
                                                                    ? BorderRadius.only(
                                                                        topLeft:
                                                                            Radius.circular(
                                                                                10),
                                                                        bottomRight:
                                                                            Radius.circular(
                                                                                10))
                                                                    : BorderRadius.only(
                                                                        topLeft:
                                                                            Radius.circular(
                                                                                10),
                                                                        bottomRight:
                                                                            Radius.circular(10))),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                      "${allMessages[i].data()['msg']}"),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Text(
                                                                        formattedTime,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                10),
                                                                      ),
                                                                    ],
                                                                  ), // Display formatted time
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          position:
                                                              PopupMenuPosition
                                                                  .under,
                                                        ),
                                            ),
                                          ],
                                        );
                                      });
                            }
                            return Center(child: CircularProgressIndicator());
                          });
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              )),
          SingleChildScrollView(
            child: Expanded(
                flex: 2,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        onChanged: (value) {
                          ischange = value.isNotEmpty;
                        },
                        controller: chatControoler,
                        decoration: InputDecoration(
                            hintText: "Type Here",
                            suffixIcon: GestureDetector(
                                onTap: (ischange)
                                    ? () async {
                                        String msg = chatControoler.text;
                                        await FirestoreHelper.firestoreHelper
                                            .sendMessage(
                                                msg: msg,
                                                receiverEmail:
                                                    reciever['email']);
                                        chatControoler.clear();
                                        await FCMNotificationHelper
                                            .fCMNotificationHelper
                                            .sendFCM(
                                                msg: "Hello",
                                                senderEmail: AuthHelper
                                                    .firebaseAuth
                                                    .currentUser!
                                                    .email!,
                                                token: reciever['token']);
                                      }
                                    : null,
                                child: Icon(
                                  Icons.send,
                                  color: (ischange)
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                                )),
                            border: OutlineInputBorder()),
                      ),
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
