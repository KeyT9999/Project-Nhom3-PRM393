import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore? firestore;

  FirestoreService({this.firestore});

  FirebaseFirestore get db => firestore ?? FirebaseFirestore.instance;
}
