import 'dart:math';

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
        title: const Text('เช็คหนังสือ'),
      ),
      drawer: MyDrawer(),
      body: Container(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      color: Color.fromARGB(255, 255, 249, 171),
                      child: Container(
                        width: 500,
                        height: 270,
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              "ผลการสแกน",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Obx(
                              () => bookController.isLoading.value
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text("Searching")
                                      ],
                                    )
                                  : Text(bookController.resultSearch.value),
                            ),
                            const SizedBox(height: 40),
                            TextField(
                              controller: textEditingController,
                              decoration: const InputDecoration(
                                  labelText:
                                      'สแกนบาร์โค้ดหรือกรอกหมายเลขบาร์โค้ดที่นี่'),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (textEditingController.text.isNotEmpty &&
                                    bookController.checkdbAvial() == true) {
                                  bookController.findFromBarcode(
                                      textEditingController.text);
                                } else if (textEditingController
                                        .text.isNotEmpty &&
                                    bookController.checkdbAvial() == false) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("กรุณาดึงข้อมูลหนังสือก่อน"),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                } else if (textEditingController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("กรุณากรอกหมายเลขบาร์โค้ด"),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                } else if (textEditingController
                                        .text.isNotEmpty &&
                                    bookController.checkdbAvial() == false) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("กรุณาดึงข้อมูลหนังสือก่อน"),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                              child: const Text('ค้นหา'),
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
            Expanded(
              child: GetX<scanDBhelper>(
                builder: (controller) {
                  if (controller.todo.length == 0) {
                    // Display a message when no books are checked
                    return Center(
                      child: Text(
                        'No books checked.',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  } else {
                    // Display the ListView.builder when there are books checked
                    return ListView.builder(
                      itemCount: min(5, controller.todo.length),
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            controller.todo[index].title.length <= 50
                                ? controller.todo[index].title
                                : '${controller.todo[index].title.substring(0, 50)}...',
                          ),
                          subtitle: Text(controller.todo[index].barcode),
                          trailing: controller.todo[index].found == "Y"
                              ? Image.asset(
                                  'assets/images/correct.png',
                                  width: 50,
                                  height: 50,
                                )
                              : Image.asset(
                                  'assets/images/incorrect.png',
                                  width: 50,
                                  height: 50,
                                ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
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
