import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/bookcontroller.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:qr_scan/controller/scannercontroller.dart';
import 'package:qr_scan/screen/navbar.dart';

class Scanview extends StatelessWidget {
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
      drawer: MyDrawer(), // Add the drawer here
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Color.fromARGB(255, 255, 249, 171),
                child: Container(
                  width: 500,
                  height: 370,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "Scan Result",
                        style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      Obx(
                        () => bookController.isLoading.value
                            ? Row(mainAxisAlignment: MainAxisAlignment.center,
                              children: [CircularProgressIndicator() ,SizedBox(width: 20,),Text("Searching")],)
                            : Text(bookController.resultSearch
                                .value), 
                      ),
                      const SizedBox(height: 40),
                      TextField(
                        controller: textEditingController,
                        decoration: const InputDecoration(
                            labelText:
                                'Scan Barcode or InsertBarcode NO. Here'),
                      ),
                      const SizedBox(
                        height: 30,
                      ),

                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (textEditingController.text.isNotEmpty &&
                              bookController.checkdbAvial() == true) {
                            bookController
                                .findFromBarcode(textEditingController.text);
                          } else if (textEditingController.text.isNotEmpty &&
                              bookController.checkdbAvial() == false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please Add DB"),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          } else if (textEditingController.text.isEmpty &&
                              bookController.checkdbAvial() == false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please Add DB"),
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
              const SizedBox(height: 20),
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
