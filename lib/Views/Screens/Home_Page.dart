import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_miner/Views/components/my_drawer.dart';
import 'package:firebase_miner/utils/auth_helper.dart';
import 'package:firebase_miner/utils/firestore_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    User user = ModalRoute.of(context)!.settings.arguments as User;

    // User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "HomePage",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffFABC3F),
        actions: [
          IconButton(
              onPressed: () {
                AuthHelper.authHelper.signOutUser();
                Get.back();
              },
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ))
        ],
      ),
      drawer: MyDrawer(
        user: user!,
      ),
      body: StreamBuilder(
        stream: FirestoreHelper.firestoreHelper.fetchAllUsers(),
        builder: (context, ss) {
          if (ss.hasError) {
            return Center(
              child: Text("ERROR: ${ss.error}"),
            );
          } else if (ss.hasData) {
            QuerySnapshot<Map<String, dynamic>>? data = ss.data;
            List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                (data == null) ? [] : data.docs;
            return ListView.separated(
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () {
                    Get.toNamed('/Chat_page', arguments: allDocs[i].data());
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text("${i + 1}"),
                      ),
                      title: (AuthHelper.firebaseAuth.currentUser!.email ==
                              allDocs[i].data()['email'])
                          ? Text(" you ${allDocs[i].data()['email']}")
                          : Text("${allDocs[i].data()['email']}"),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Container();
              },
              itemCount: allDocs.length,
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
