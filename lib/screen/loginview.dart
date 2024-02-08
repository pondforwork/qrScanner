import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/screen/navbar.dart';
import 'package:qr_scan/screen/scanview.dart';

class LoginView extends StatefulWidget {
  LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final Future<FirebaseApp> _firebase;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }
   Future<FirebaseApp> initializeFirebase() async {
    try {
      return await Firebase.initializeApp();
    } catch (e) {
      print('Error initializing Firebase: $e');
    throw e; // Rethrow the error to handle it at a higher level if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              child: Text(
                "เข้าสู่ระบบ",
                style: TextStyle(fontSize: 35),
              ),
            ),
          ),
          SizedBox(
            height: 100,
          ),
          Center(
            child: SizedBox(
              width: 350,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: ElevatedButton(
                  onPressed: () async {
                    await loginEmailAndPassword();
                    print("Test");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/Google_Icon.png',
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "เข้าสู่ระบบด้วย Google",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> loginEmailAndPassword() async {
    try {
      await _firebase; // Ensure Firebase is initialized
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "ponduuu123@gmail.com",
        password: "Pxnd124",
      );
      // Navigate to the next screen or perform other actions upon successful login
    } on FirebaseAuthException catch (e) {
      print(e.message);
      // Handle login error (show message to user, etc.)
    }
  }
}
