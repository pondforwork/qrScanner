import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
              const SizedBox(
                height: 60,
              ),
              const Text(
                "Current Database",
                style: TextStyle(fontSize: 25),
              ),
              Obx(() => Text(scandbController.currentdb.value)),
              Expanded(
                  child: TextButton(
                onPressed: () {
                  bookController.openDatabaseConnection();
                },
                child: const Text("SELECT DB"),
              )),
              Expanded(
                  child: TextButton(
                onPressed: () {
                  scandbController.getDBName();
                },
                child: const Text("CheckDBName"),
              )), Expanded(
                  child: TextButton(
                onPressed: () {
                  scandbController.setDBName("BBB");
                },
                child: const Text("Add Dbname"),
              )), Expanded(
                  child: TextButton(
                onPressed: () {
                  scandbController.clearDBNameBox();
                },
                child: const Text("Clearname"),
              ))
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
