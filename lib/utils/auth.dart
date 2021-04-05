import 'package:dev_try/utils/api.dart';
import 'package:dev_try/utils/user.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserRepository with ChangeNotifier {
  FirebaseAuth auth;
  User _user;
  GoogleSignIn _googleSignIn;
  Status _status = Status.Uninitialized;

  UserRepository.instance()
      : auth = FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn() {
    FirebaseAuth.instance.authStateChanges().listen((_onAuthStateChanged));
  }

  Status get status => _status;
  User get user => _user;

  Future<bool> signInWithGoogle() async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      GoogleSignInAccount googleAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuthentication = await googleAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuthentication.idToken,
        accessToken: googleAuthentication.accessToken,
      );
      await auth.signInWithCredential(credential);
      UserData note = UserData(name: user.displayName, photoUrl: user.photoURL, uid: user.uid);
      await Api("users").addNote(note);
      print("im here");

      return true;
    } catch (e) {
      print(e);
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    auth.signOut();
    _googleSignIn.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();

    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User user) async {
    if (user == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = user;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }
}
