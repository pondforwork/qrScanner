import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/usercontroller.dart';




class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);
  
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final UserController usercontroller = Get.put(UserController());


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
                    // signInWithGoogle();
                    // await loginEmailAndPassword();
                    await  usercontroller.signInWithGoogle();
                    Get.back();
                 
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

  
}
