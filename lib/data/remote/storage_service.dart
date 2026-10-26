import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage? storageInstance;

  StorageService({this.storageInstance});

  FirebaseStorage get storage => storageInstance ?? FirebaseStorage.instance;
}
