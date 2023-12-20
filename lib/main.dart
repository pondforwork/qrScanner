import 'package:flutter/material.dart';
import 'package:qr_scan/screen/mainview.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainView()
    );
  }
}
