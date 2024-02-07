import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/bookcontroller.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';

class ScannerController extends GetxController {
  RxString barcodeResult = "No data yet. Please Scan QR or Barcode".obs;
  RxString barcode = ''.obs;
  List<String> list = ['One', 'Two', 'Three', 'Four'];
  final BookController bookcontroller = Get.put(BookController());

// Initialize the database

  Future<void> scanBarcode() async {
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666", // Color for the scan button
      "Cancel", // Text for the cancel button
      true, // Show flash icon
      ScanMode.DEFAULT, // Specify the type of scan
    );
    barcodeResult.value = barcodeScanResult;
    if (barcodeResult.value == "-1") {
      barcodeResult.value = "No data yet. Please Scan QR or Barcode";
    }
  }

  Future<void> scanBarcodeAndSearchDB(value) async {
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666", // Color for the scan button
      "Cancel", // Text for the cancel button
      true, // Show flash icon
      ScanMode.DEFAULT, // Specify the type of scan
    );
    barcodeResult.value = barcodeScanResult;
    if (barcodeResult.value == "-1") {
      barcodeResult.value = "No data yet. Please Scan QR or Barcode";
    } else {
      BookController().findFromBarcode(barcodeScanResult);
    }
    BookController().findFromBarcode(value);
  }


  Future<void> scanandsearchFromDB() async {
    try {
      // Trigger loading indicator before starting the scanning operation
      BookController().isLoading.value = true;

      String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", // Color for the scan button
        "Cancel", // Text for the cancel button
        true, // Show flash icon
        ScanMode.DEFAULT, // Specify the type of scan
      );

      // Check if the scanning result is "-1"
      if (barcodeScanResult == "-1") {
        barcodeResult.value = "No data yet. Please Scan QR or Barcode";
      } else {
        // Perform the search operation using the obtained barcode
        barcode.value = barcodeScanResult;
        
      }
    } finally {
      // Ensure the loading indicator is turned off, even in case of an exception
      BookController().isLoading.value = false;
    }
  }

  // bookController.findFromBarcode(textEditingController.text);
}
