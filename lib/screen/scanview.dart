import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/bookcontroller.dart';
import 'package:qr_scan/controller/dropdowncontroller.dart';
import 'package:qr_scan/controller/scannercontroller.dart';

class DropdownPage extends StatelessWidget {
  final DropdownController dropdownController = Get.find();
  final ScannerController scannercontroller = Get.put(ScannerController());
  final TextEditingController textEditingController = TextEditingController();
  final BookController bookController = Get.put(BookController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanning Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Obx widget for reactive updates
              Card(
                color: Color.fromARGB(
                    255, 255, 249, 171), // Set the background color of the Card
                child: Container(
                  width: 500,
                  height: 370,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "Scan Result",
                        style: TextStyle(fontSize: 25),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Obx(() => Text(scannercontroller.barcodeResult.value)),


                      Obx(() => Text(bookController.resultSearch.value)),
                      //  Text(scannercontroller.barcodeResult.value),
                      SizedBox(height: 10), // Add some spacing
                      TextField(
                        controller: textEditingController,
                        decoration:
                            const InputDecoration(labelText: 'Enter Name'),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                     
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          bookController.findFromBarcode(textEditingController.text);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
            
 
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // scannercontroller.barcodeResult.value="Tdasadsf";
          scannercontroller.scanandsearchFromDB();
        },
        child: Icon(Icons.qr_code_2_outlined),
      ),
    );
  }

  void clearForm() {
    scannercontroller.barcodeResult.value =
        "No data yet. Please Scan QR or Barcode";
    textEditingController.text = ''; // Clear the text field
    dropdownController.selectedItem.value = dropdownController
        .dropdownItems[0]; // Reset the selected item in the dropdown
  }
}
