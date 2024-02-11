import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qr_scan/screen/mainview.dart';

class UserController extends GetxController {
  RxString currentUser = ''.obs;
  @override
  Future<void> onInit() async {
    super.onInit();
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Initialize the GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // If the user cancels the sign-in, googleUser will be null
      if (googleUser == null) {
        print("Google sign-in canceled");
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Sign in to Firebase with the Google [UserCredential]
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      print("User signed in: ${userCredential.user?.displayName}");
      currentUser.value = userCredential.user!.displayName!;
      print(currentUser.value);

      // Return the user
      return userCredential.user;
    } catch (error) {
      // Handle specific errors or log the general error
      print("Error signing in with Google: $error");

      // You can handle different types of errors here if needed
      // For example, you might want to differentiate between login failure and cancellation
      if (error is FirebaseAuthException) {
        if (error.code == 'user-not-found') {
          // Handle the case where the user is not found
        } else if (error.code == 'wrong-password') {
          // Handle the case where the password is incorrect
        }
      }

      // Return null or handle the error in an appropriate way
      return null;
    }
  }

  Future<void> signOut() async {
    // Initialize the GoogleSignIn
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await googleSignIn.signOut(); // Sign out from Google
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      currentUser.value = ""; // Reset the current user value
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  // Future<void> checkCurrent() async {
  //   // Initialize the GoogleSignIn
  //   final GoogleSignIn googleSignIn = GoogleSignIn();
  //   print("User signed in: ${userCredential.user?.displayName}");

  //   try {
  //     await googleSignIn.signOut(); // Sign out from Google
  //     await FirebaseAuth.instance.signOut(); // Sign out from Firebase
  //     currentUser.value = ""; // Reset the current user value
  //   } catch (e) {
  //     print("Error signing out: $e");
  //   }
  // }

  userloggedIn() {
    if (currentUser.value == "") {
      return false;
    } else {
      return true;
    }
  }
}
