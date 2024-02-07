import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/bookcontroller.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:qr_scan/controller/scannercontroller.dart';

class DropdownPage extends StatelessWidget {
  final ScannerController scannercontroller = Get.put(ScannerController());
  final TextEditingController textEditingController = TextEditingController();
  final BookController bookController = Get.put(BookController());
  final scanDBhelper scandbhelper = Get.put(scanDBhelper());

  

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
                      // Obx(() => Text(scannercontroller.barcodeResult.value)),
                      SizedBox(
                        height: 35,
                      ),
                      Obx(
                        () => bookController.isLoading.value
                            ? CircularProgressIndicator() // Show loading indicator
                            : Text(bookController.resultSearch
                                .value), // Display resultSearch value
                      ),
                      //  Text(scannercontroller.barcodeResult.value),
                      SizedBox(height: 40), // Add some spacing
                      TextField(
                        controller: textEditingController,
                        decoration: const InputDecoration(
                            labelText:
                                'Scan Barcode or InsertBarcode No. Here'),
                      ),
                      SizedBox(
                        height: 30,
                      ),

                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (textEditingController.text.isNotEmpty) {
                            bookController
                                .findFromBarcode(textEditingController.text);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a barcode"),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        child: const Text('Search'),
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
        onPressed: () async {
          // scannercontroller.barcodeResult.value="Tdasadsf";
          await scannercontroller.scanandsearchFromDB();
          await bookController.findFromBarcode(scannercontroller.barcode.value);
          print(scannercontroller.barcode.value);
        },
        child: Icon(Icons.qr_code_2_outlined),
      ),
    );
  }

}
