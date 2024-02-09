import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:qr_scan/screen/mainview.dart';
import 'package:qr_scan/screen/scanview.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure plugin services are initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: DropdownPage(),
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
              color: Colors.blue,
              titleTextStyle: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold)),
          scaffoldBackgroundColor: Colors.white),
    );
  }
}
