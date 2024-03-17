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
                      const Text("Downloading "),
                      Text(bookController.loadingprogress.value + " %"),
                    ],
                  );
                } else if (bookController.checkdbAvial() == false) {
                  return const Text("No DB Selected");
                } else {
                  if (bookController.unzippingstatus.value == true) {
                    return const Text("Unziping");
                  } else {
                    return const Text("Fetch DB Success");
                  }
                }
              }),
              // ignore: prefer_const_constructors
              SizedBox(
                height: 150,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: bookController.isDownloadingDB
                          .value // Check if downloading is in progress
                      ? null // If downloading is in progress, disable the button
                      : () async {
                          // If not downloading, initiate the download and apply process
                          if (await internetContoller
                              .checkInternetConnection()) {
                            await bookController.downloadandapplyDB();
                          } else {
                            internetContoller.shownoInternetDialog();
                          }
                        },
                  child: const Text(
                      "ดึงข้อมูลหนังสือ"), // Displayed text on the button
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
