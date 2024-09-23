import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/bookcontroller.dart';
import 'package:qr_scan/screen/cameraview.dart';
import 'checkedbookcontroller.dart';

class ScannerController extends GetxController {
  RxString barcodeResult = "No data yet. Please Scan QR or Barcode".obs;
  RxString barcode = ''.obs;
  final BookController bookController = Get.put(BookController());
  final scanDBhelper scandbhelper = Get.put(scanDBhelper());

  Future<void> scanNew() async {
    if (scandbhelper.currentdb.value != "No Database Selected") {
      Get.to(CameraView());
    } else {
      Get.snackbar(
        'ยังไม่ได้ดึงโหลดข้อมูลหนังสือ', // Title
        'กรุณาดึงข้อมูลหนังสือก่อนทำการสแกน', // Message
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.yellow,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> searchFromDB(String barcode_value) async {}
}
