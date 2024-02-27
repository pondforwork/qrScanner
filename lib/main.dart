import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/screen/loginview.dart';
import 'package:qr_scan/screen/scanview.dart';

import 'controller/usercontroller.dart';

Future<void> main() async {
  UserController userController = Get.put(UserController());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await userController.userloggedIn();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Obx(
        () {
          var userLoggedIn = userController.hasUserLoggedin.value;
          return userLoggedIn ? Scanview() : LoginView();
        },
      ),
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white),
            color: Colors.green,
            titleTextStyle: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          ),
          scaffoldBackgroundColor: Colors.white),
    );
  }
}
