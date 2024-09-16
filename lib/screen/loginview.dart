import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/usercontroller.dart';

import 'scanview.dart';

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
      // backgroundColor: Color(0xFF0AA877),
      backgroundColor: Colors.green,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
                child: Image.asset(
              'assets/images/LoginLogo.png',
              width: 300,
              height: 300,
            )),
          ),
          const SizedBox(
            height: 50,
          ),
          const SizedBox(
            child: Text(
              "BUU LIBRARY",
              style: TextStyle(
                  fontSize: 50,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 70,
          ),
          Column(
            children: [
              Center(
                child: SizedBox(
                  width: 350,
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: ElevatedButton(
                      onPressed: () async {
                        // signInWithGoogle();
                        // await loginEmailAndPassword();
                        await usercontroller.signInWithGoogle();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
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
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // const SizedBox(
              //   height: 30,
              // ),
              // Center(
              //   child: SizedBox(
              //     width: 350,
              //     child: Padding(
              //       padding: const EdgeInsets.all(0),
              //       child: ElevatedButton(
              //         onPressed: () async {
              //           // signInWithGoogle();
              //           // await loginEmailAndPassword();
              //           Get.offAll(() => Scanview());
              //         },
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.white,
              //           minimumSize: const Size(150, 50),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(50),
              //           ),
              //         ),
              //         child: const Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             SizedBox(width: 8),
              //             Text(
              //               "เข้าสู่ระบบในฐานะ Guest",
              //               style: TextStyle(
              //                 color: Colors.black,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          )
        ],
      ),
    );
  }
}
