import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/bookcontroller.dart';

class ScannerController extends GetxController {
  RxString barcodeResult = "No data yet. Please Scan QR or Barcode".obs;
  RxString barcode = ''.obs;
  List<String> list = ['One', 'Two', 'Three', 'Four'];
  final BookController bookController = Get.put(BookController());
  Future<void> scanBarcode() async {
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666",
      "Cancel",
      true,
      ScanMode.DEFAULT,
    );
    barcodeResult.value = barcodeScanResult;
    if (barcodeResult.value == "-1") {
      barcodeResult.value = "No data yet. Please Scan QR or Barcode";
    }
  }

  // Future<void> scanBarcodeAndSearchDB(value) async {
  //   scan.value = true;
  //   String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
  //     "#ff6666",
  //     "Cancel",
  //     true,
  //     ScanMode.DEFAULT,
  //   );
  //   barcodeResult.value = barcodeScanResult;
  //   if (barcodeResult.value == "-1") {
  //     barcodeResult.value = "No data yet. Please Scan QR or Barcode";
  //     scan.value = false;
  //   } else {
  //     BookController().findFromBarcode(barcodeScanResult);
  //   }
  //   BookController().findFromBarcode(value);
  // }

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
        barcode.value = barcodeScanResult;
        await bookController.findFromBarcode(barcode.value);
      }
    } finally {
      BookController().isLoading.value = false;
    }
  }
}
