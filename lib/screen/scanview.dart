import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';

class ScanController extends GetxController {
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

class ScanScreen extends StatelessWidget {
  final ScanController _controller = Get.put(ScanController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text(
                  'Scan Result: ${_controller.barcodeResult}',
                  style: TextStyle(fontSize: 20),
                )),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _controller.dropdownValue.value,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? value) {
                // This is called when the user selects an item.
                _controller.dropdownValue.value = value!;
              },
              items: _controller.list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _controller.scanBarcode();
              },
              child: Text('Scan Barcode'),
            ),
          ],
        ),
      ),
    );
  }
}


