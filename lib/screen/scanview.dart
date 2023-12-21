import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/dropdowncontroller.dart';
import 'package:qr_scan/controller/scannercontroller.dart';

class DropdownPage extends StatelessWidget {
  final DropdownController dropdownController = Get.find();
  final ScannerController scannercontroller = Get.put(ScannerController());
  final TextEditingController textEditingController = TextEditingController();

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
                  height: 300,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("Scan Result",style: TextStyle(fontSize: 25),),
                      SizedBox(
                        height: 20,
                      ),
                      Obx(() => Text(scannercontroller.barcodeResult.value)),
                      //  Text(scannercontroller.barcodeResult.value),
                      SizedBox(height: 10), // Add some spacing
                      TextField(
                        controller: textEditingController,
                        decoration:
                            const InputDecoration(labelText: 'Enter Name'),
                      ),

                      Obx(
                        () => DropdownButton(
                          value:
                              dropdownController.selectedItem.value.isNotEmpty
                                  ? dropdownController.selectedItem.value
                                  : dropdownController.dropdownItems.isNotEmpty
                                      ? dropdownController.dropdownItems[0]
                                      : null,
                          items: dropdownController.dropdownItems
                              .map(
                                (String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                          onChanged: (String? selectedItem) {
                            // Update the selected value in the controller
                            dropdownController.selectedItem.value =
                                selectedItem!;

                            // Handle the selected item (you can remove this if you don't need it)
                            print("Selected Item: $selectedItem");
                          },
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          String name = textEditingController.text;
                          print(name);
                          print(dropdownController.selectedItem.value);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              // Display the selected item
              // Obx(
              //   () => Text(
              //     'Selected Item: ${dropdownController.selectedItem}',
              //     style: TextStyle(fontSize: 18),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // scannercontroller.barcodeResult.value="Tdasadsf";
          // scannercontroller.scanBarcode();
        },
        child: Icon(Icons.qr_code_2_outlined),
      ),
    );
  }
}
