import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FirebaseAuth getFirebaseAuthInstance() => _firebaseAuth;

  User? getAuthUser() => _firebaseAuth.currentUser;

  FirebaseMessaging getMessaging() => _firebaseMessaging;

  updateUserInfos(String name, String photo) async {
    User? user = _firebaseAuth.currentUser;

    await user?.updateDisplayName(name);
    await user?.updatePhotoURL(photo);
    await user?.reload();
  }

  Future<String> getToken() async {
    if (getAuthUser() != null) {
      return await getAuthUser()!.getIdToken();
    } else {
      throw Exception("Usuário não está logado.");
    }
  }
}
