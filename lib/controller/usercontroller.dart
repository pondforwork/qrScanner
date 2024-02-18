import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qr_scan/screen/mainview.dart';

class UserController extends GetxController {
  RxString currentUser = 'Guest'.obs;
  @override
  Future<void> onInit() async {
    super.onInit();
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print("Google sign-in canceled");
        return null;
      }
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user?.email?.endsWith("@go.buu.ac.th") ?? false) {
        print("User signed in: ${userCredential.user?.displayName}");
        currentUser.value = userCredential.user!.displayName!;
        print(currentUser.value);

        return userCredential.user;
      } else {
        print("Invalid email domain. Sign-in not allowed.");
        await googleSignIn.signOut();
        return null;
      }
    } catch (error) {
      print("Error signing in with Google: $error");
      if (error is FirebaseAuthException) {
        if (error.code == 'user-not-found') {
        } else if (error.code == 'wrong-password') {}
      }
      return null;
    }
  }

  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      currentUser.value = "Guest";
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  userloggedIn() {
    if (currentUser.value == "") {
      return false;
    } else {
      return true;
    }
  }
}
