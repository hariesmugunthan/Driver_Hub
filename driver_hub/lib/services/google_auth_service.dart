import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  //inilitize google signin
  Future<void> initializeGoogleSignIn() async {
    await GoogleSignIn.instance.initialize();
  }

  Future<String> signInWithGoogle() async {
    GoogleSignInAccount googleAccount = await GoogleSignIn.instance.authenticate();

    GoogleSignInAuthentication googleAuthentication = googleAccount.authentication;

    String? idToken = googleAuthentication.idToken;

    if (idToken == null) {
      throw Exception('Google ID token was not received');
    }

    //this makes the credentials in a format that fire base can use
    OAuthCredential googleCredential = GoogleAuthProvider.credential(idToken: idToken);

    //fire base uses that credential ans firebase opens a session makes the authenticated user available
    await FirebaseAuth.instance.signInWithCredential(googleCredential);

    String? firebaseIdToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    if (firebaseIdToken == null) {
      throw Exception('Firebase ID token was not received');
    }

    return firebaseIdToken;
  }

  Future<void> signOutFromGoogle() async {
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();
  }
}