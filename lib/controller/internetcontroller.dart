import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InternetContoller extends GetxController {
  Future<bool> checkInternetConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  void shownoInternetDialog() {
    Get.defaultDialog(
      title: "ไม่มีการเชื่อมต่อ",
      content: const SizedBox(
        width: 200,
        height: 100,
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(), // Disable scrolling
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center content vertically
            children: [
              Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Text(
                  "กรุณาเชื่อมต่ออินเทอร์เน็ตแล้วลองอีกครั้ง",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("ตกลง"),
        ),
      ],
    );
  }
}
