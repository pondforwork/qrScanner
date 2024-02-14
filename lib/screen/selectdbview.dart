import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_scan/controller/bookcontroller.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:qr_scan/controller/scannercontroller.dart';

class SelectDBview extends StatelessWidget {
  SelectDBview({Key? key}) : super(key: key);
  final ScannerController scannercontroller = Get.put(ScannerController());
  final BookController bookController = Get.put(BookController());
  final scanDBhelper scandbController = Get.put(scanDBhelper());

  @override
  Widget build(BuildContext context) {
    Get.put(BookController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Database"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20), // Adjust the height as needed
              const Text(
                "Current Database",
                style: TextStyle(fontSize: 25),
              ),
              const SizedBox(height: 50),
              Obx(() {
                if (bookController.isDownloadingDB.value == true) {
                  return const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        width: 20,
                      ),
                      Text("Downloading"),
                    ],
                  );
                } else {
                  return Obx(() => Text(scandbController.currentdb.value));
                }
                // Other code when not downloading
              }),

              const SizedBox(height: 50),

              // Obx(() => Text(scandbController.currentdb.value)),
              const SizedBox(height: 450),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    //bookController.openDatabaseConnection();
                    bookController.downloadFile();
                  },
                  child: const Text("SELECT DB"),
                ),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   scannercontroller.scanBarcode();

      //   // ScannerController().barcodeResult();
      // }),
    );
  }
}
