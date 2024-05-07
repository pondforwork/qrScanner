import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/bookcontroller.dart';
import 'package:qr_scan/screen/cameraview.dart';
import 'checkedbookcontroller.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:native_barcode_scanner/barcode_scanner.dart';
import 'package:native_barcode_scanner/barcode_scanner.widget.dart';

class ScannerController extends GetxController {
  RxString barcodeResult = "No data yet. Please Scan QR or Barcode".obs;
  RxString barcode = ''.obs;
  final BookController bookController = Get.put(BookController());
  final scanDBhelper scandbhelper = Get.put(scanDBhelper());

  // Future<void> scanBarcode() async {
  //   String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
  //     "#ff6666",
  //     "Cancel",
  //     true,
  //     ScanMode.DEFAULT,
  //   );
  //   barcodeResult.value = barcodeScanResult;
  //   if (barcodeResult.value == "-1") {
  //     barcodeResult.value = "No data yet. Please Scan QR or Barcode";
  //   }
  // }

  Future<void> scanNew() async {
    if (bookController.checkdbAvial() == false) {
      Get.snackbar(
        'ยังไม่ได้ดึงโหลดข้อมูลหนังสือ', // Title
        'กรุณาดึงข้อมูลหนังสือก่อนทำการสแกน', // Message
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.yellow,
        duration: const Duration(seconds: 3),
      );
    } else {
      var res = await Get.to(CameraView());
    }
  }

  Future<void> searchFromDB(String barcode_value) async {}

  Future<void> scanandsearchFromDB() async {
    bookController.continuousScan.value = true;
    try {
      BookController().isLoading.value = true;
      String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true, // Show flash icon
        ScanMode.DEFAULT,
      );

      if (barcodeScanResult == "-1") {
        print("Cancel");
        barcodeResult.value = "No data yet. Please Scan QR or Barcode";
        bookController.continuousScan.value = false;
      } else {
        // Check ว่า มี A นำหน้า และ ต่อท้ายไหม ถ้ามี ให้ตัดออก
        if (barcodeScanResult.startsWith('A') &&
            barcodeScanResult.endsWith('A')) {
          barcodeScanResult =
              barcodeScanResult.substring(1, barcodeScanResult.length - 1);
        }
        if (scandbhelper.checkDuplicateBook(barcodeScanResult)) {
          bookController.showDuplicateSnackbar();
        } else {
          barcode.value = barcodeScanResult;
          await bookController.findFromBarcode(barcode.value);
        }
      }
    } finally {
      BookController().isLoading.value = false;
    }
  }
}
