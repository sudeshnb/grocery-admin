import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthBase {
  Stream<User?> get onAuthStateChanged;

  Future<void> editImage(String path);

  Future<void> updateNameAndEmail(String email, String name);

  Future<void> changePassword(String password);

  String get uid;

  String? get email;


  Future<String> get token;

  String? get profileImage;

  String? get displayName;

  Future<void> signInWithEmailAndPassword(String email, String password);

  Future<void> signOut();
}

class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;

  String get uid => _firebaseAuth.currentUser!.uid;

  @override
  String get email => _firebaseAuth.currentUser!.email ?? "";

  @override
  String? get displayName => _firebaseAuth.currentUser!.displayName;

  @override
  String? get profileImage => _firebaseAuth.currentUser!.photoURL;

  @override
  Future<void> editImage(String path) async {
    await _firebaseAuth.currentUser!.updatePhotoURL(path);
  }

  Future<void> updateNameAndEmail(String email, String name) async {
    await _firebaseAuth.currentUser!.updateDisplayName(name);

    await _firebaseAuth.currentUser!.updateEmail(email);
  }

  Future<void> changePassword(String password) async {
    await _firebaseAuth.currentUser!.updatePassword(password);
  }

  @override
  Stream<User?> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges();
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  // TODO: implement token
  Future<String> get token => _firebaseAuth.currentUser!.getIdToken();


}
