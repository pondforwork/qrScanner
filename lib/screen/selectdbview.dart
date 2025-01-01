import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/bookcontroller.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:qr_scan/controller/internetcontroller.dart';
import 'package:qr_scan/controller/scannercontroller.dart';

class SelectDBview extends StatelessWidget {
  SelectDBview({Key? key}) : super(key: key);
  final ScannerController scannercontroller = Get.put(ScannerController());
  final BookController bookController = Get.put(BookController());
  final scanDBhelper scandbController = Get.put(scanDBhelper());
  final InternetContoller internetContoller = InternetContoller();

  @override
  Widget build(BuildContext context) {
    Get.put(BookController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("ดึงข้อมูลหนังสือ"),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.bug_report),
        //     onPressed: () {
        //       // bookController.testInsert();
        //       bookController.pickFile();
        //       print("Test");
        //     },
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.download),
        //     onPressed: () {
        //       bookController.downloadfileIos();
        //     },
        //   ),
        // ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "สถานะฐานข้อมูลหนังสือ",
                style: TextStyle(fontSize: 25),
              ),
              const SizedBox(height: 150),
              Obx(() {
                if (bookController.isDownloadingDB.value == true) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(
                        width: 20,
                      ),
                      const Text("กำลังดาวน์โหลด "),
                      Text(bookController.loadingprogress.value + " %"),
                    ],
                  );
                } else if (bookController.checkdbAvial() == false) {
                  return const Text("ยังไม่ได้ดึงข้อมูลหนังสือ");
                } else {
                  if (bookController.unzippingstatus.value == true) {
                    return const Text("กำลังแตกไฟล์");
                  } else {
                    return const Text("ดึงข้อมูลหนังสือแล้ว");
                  }
                }
              }),
              // ignore: prefer_const_constructors
              SizedBox(
                height: 50,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: bookController.isDownloadingDB.value ||
                          scandbController.currentdb.value !=
                              "No Database Selected"
                      ? null // If downloading is in progress or a database is selected, disable the button
                      : () async {
                          bookController.showPasswordDialog();
                        },
                  child: const Text(
                    "ดึงข้อมูลหนังสือ", // Displayed text on the button
                  ),
                ),
              ),
              const SizedBox(
                height: 250,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                        ),
                        onPressed: () async {
                          bookController.showDialog();
                          // bookController.resetBookDB();
                        },
                        child: const Text(
                          "รีเซ็ตฐานข้อมูลหนังสือ",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
