import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_scan/screen/mainview.dart';

import '../screen/scanview.dart';

class UserController extends GetxController {
  RxString currentUser = 'Guest'.obs;
  RxString currentUserEmail = 'No-Email'.obs;
  RxBool hasUserLoggedin = false.obs;
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
        currentUserEmail.value = userCredential.user!.email!;
        setUsernameOnHive(currentUser.value);
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
      currentUserEmail.value = "No-Email";
      setUsernameOnHive(currentUser.value);
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  userloggedIn() async {
    await initHive();
    await getUsernameFromHive();
    if (currentUser.value == "" || currentUser.value == "Guest") {
      print(currentUser.value);
      print("False");
      hasUserLoggedin.value = false;
      return false;
    } else {
      print(currentUser.value);
      hasUserLoggedin.value = true;
      print("True");
      return true;
    }
  }

  Future<void> setUsernameOnHive(String username) async {
    try {
      var box = await Hive.openBox('username');
      await box.put(1, username);
      print("Success Set Username");
    } catch (error) {
      print('Error while setting username: $error');
    }
  }

  Future<void> getUsernameFromHive() async {
    try {
      var box = await Hive.openBox('username');
      String username = box.get(1);
      currentUser.value = username;
      print("Retrieved Username: $username");
    } catch (error) {
      print('Error while getting username: $error');
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

  Future<void> initHive() async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    try {
      await Hive.initFlutter(documentDirectory.path);
      await Hive.openBox('checkedbook');
      await Hive.openBox('dbname');
    } catch (error) {
      print("Hive initialization error: $error");
    }
  }
}
