import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qr_scan/screen/mainview.dart';

import '../screen/scanview.dart';

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
        currentUser.value = userCredential.user!.displayName!;
        showSuccessSnackbar();
        Get.offAll(() => Scanview());
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
      showErrorSnackbar();
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

   void showSuccessSnackbar() {
    Get.snackbar(
      'Success',
      'User signed in: ${currentUser.value}',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
    );
  }

  void showErrorSnackbar() {
    Get.snackbar(
      'Error',
      'Invalid email domain. Sign-in not allowed.',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
    );
  }
}
