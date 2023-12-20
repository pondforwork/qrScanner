import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';

import 'categorycontroller.dart';

class ScanController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
   
    super.onInit();
  }

  final categoryController = Get.put(CategoryController());
  RxString barcodeResult = "No data yet".obs;
  RxString dropdownValue = 'One'.obs;
  late List<String> list;
  Future<void> scanBarcode() async {
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666", // Color for the scan button
      "Cancel", // Text for the cancel button
      true, // Show flash icon
      ScanMode.DEFAULT, // Specify the type of scan
    );

    barcodeResult.value = barcodeScanResult;
  }

  // Future<List<String>> getName() async {
  //   list = await categoryController.getCategoryNames();
  //   return list;
  // }
}
