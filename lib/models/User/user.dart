import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String id;
  final String email;
  final String photoUrl;
  final String displayName;
  final String phoneNumber;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.phoneNumber
  });

  factory User.fromDocument(DocumentSnapshot doc){
    return User(
        id: doc['id'],
        email: doc['email'],
        photoUrl: doc['photoUrl'],
        displayName: doc['displayName'],
        phoneNumber: doc['phoneNumber']
    );
  }
}