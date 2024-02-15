import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/screen/loginview.dart';
// import 'package:qr_scan/screen/mainview.dart';
import 'package:qr_scan/screen/scanview.dart';

import 'controller/usercontroller.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure plugin services are initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp( MainApp());
  
}

class MainApp extends StatelessWidget {
  UserController userController = Get.put(UserController());
  MainApp({super.key});
  
  @override
  
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home:  LoginView(),
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
