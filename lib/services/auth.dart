import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<User?> signWithGoogle() async {
  try{

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    final googleSignInAuthentication = await googleSignInAccount!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(idToken: googleSignInAuthentication.idToken, accessToken: googleSignInAuthentication.accessToken);
    final usercredential = await _auth.signInWithCredential(credential);
    final User? user = usercredential.user;

    assert(!user!.isAnonymous);
    assert(await user!.getIdToken() != null);

    final User? currentUser = _auth.currentUser;
    assert(currentUser!.uid == user!.uid);
    print(user);
    return user;
  } catch(e) {
    print("ERROR OCCURED IN SIGN IN!!");
    print(e);
    return null;
  }
}