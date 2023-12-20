import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';

class ScannerController extends GetxController {
  RxString barcodeResult = "No data yet".obs;
  RxString dropdownValue = 'One'.obs;
  List<String> list = ['One', 'Two', 'Three', 'Four'];

  Future<void> scanBarcode() async {
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666", // Color for the scan button
      "Cancel", // Text for the cancel button
      true, // Show flash icon
      ScanMode.DEFAULT, // Specify the type of scan
    );
    barcodeResult.value = barcodeScanResult;
  }
}
