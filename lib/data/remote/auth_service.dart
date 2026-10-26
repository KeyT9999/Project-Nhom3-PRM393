import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth? auth;

  AuthService({this.auth});

  User? get currentUser => auth?.currentUser;

  Stream<User?> get authStateChanges =>
      auth?.authStateChanges() ?? const Stream.empty();
}
