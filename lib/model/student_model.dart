import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  int? id;
  String? name;
  String email;
  int? age;
  String? token;

  UserModel({
    this.id,
    this.name,
    required this.email,
    this.age,
    this.token,
  });
}
