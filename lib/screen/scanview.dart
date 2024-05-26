import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_scan/controller/bookcontroller.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:qr_scan/controller/scannercontroller.dart';
import 'package:qr_scan/screen/historyview.dart';
import 'package:qr_scan/screen/navbar.dart';

class Scanview extends StatelessWidget {
  final ScannerController scannercontroller = Get.put(ScannerController());
  final TextEditingController textEditingController = TextEditingController();
  final BookController bookController = Get.put(BookController());
  final scanDBhelper scandbhelper = Get.put(scanDBhelper());
  final scanDBhelper checkedbookcontroller = Get.put(scanDBhelper());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เช็คหนังสือ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              // bookController.testInsert();
              bookController.showMockDataDialog();
              print("Test");
            },
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    color: const Color.fromARGB(255, 255, 249, 171),
                    child: Container(
                      width: 500,
                      height: 270,
                      padding: const EdgeInsets.all(16.0),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                  if (checkedbookcontroller.checkDuplicateBook(
                                      textEditingController.text)) {
                                    bookController.showDuplicateSnackbar();
                                    textEditingController.text = "";
                                  } else {
                                    bookController.findFromBarcode(
                                        textEditingController.text);
                                    textEditingController.text = "";
                                  }
                                } else if (textEditingController
                                        .text.isNotEmpty &&
                                    bookController.checkdbAvial() == false) {
                                  Get.snackbar(
                                    'ยังไม่ได้ดึงโหลดข้อมูลหนังสือ', // Title
                                    'กรุณาดึงข้อมูลหนังสือก่อนทำการสแกน', // Message
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.yellow,
                                    duration: const Duration(seconds: 3),
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
                              child: const SizedBox(
                                width: 65,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_sharp),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text("ค้นหา")
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
          Obx(
            () {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icon/foundbooks.png',
                          width: 35,
                          height: 35,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          checkedbookcontroller.foundqtyobs.value.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/icon/additionbooks.png',
                        width: 35,
                        height: 35,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                          checkedbookcontroller.notfoundqtyobs.value.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icon/allBooks.png',
                          width: 35,
                          height: 35,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                            (checkedbookcontroller.foundqtyobs.value +
                                    checkedbookcontroller.notfoundqtyobs.value)
                                .toString(),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: GetX<scanDBhelper>(
              builder: (controller) {
                if (controller.todo.isEmpty) {
                  return const Center(
                    child: Text(
                      'No books checked.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: min(5, controller.todo.length),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onDoubleTap: () {
                          Get.to(HistoryView());
                        },
                        child: ListTile(
                          title: Text(
                            controller.todo[index].title.length <= 50
                                ? controller.todo[index].title
                                : '${controller.todo[index].title.substring(0, 50)}...',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(controller.todo[index].barcode),
                              Text(
                                "บันทึกเมื่อ ${DateFormat('dd/MM/yyyy HH:mm:ss').format(controller.todo[index].checktime)}",
                              ),
                            ],
                          ),
                          trailing: FittedBox(
                            child: Row(
                              children: [
                                controller.todo[index].found == "Y"
                                    ? Image.asset(
                                        'assets/icon/foundbooks.png',
                                        width: 40,
                                        height: 40,
                                      )
                                    : Image.asset(
                                        'assets/icon/additionbooks.png',
                                        width: 40,
                                        height: 40,
                                      ),
                                const SizedBox(
                                  width: 10,
                                ),
                                controller.todo[index].exportstatus == false
                                    ? Image.asset(
                                        'assets/icon/didntexported.png',
                                        width: 40,
                                        height: 40,
                                      )
                                    : Image.asset(
                                        'assets/icon/exported.png',
                                        width: 40,
                                        height: 40,
                                      ),
                              ],
                            ),
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          scannercontroller.scanNew();
        },
        child: const Icon(Icons.qr_code_2_outlined),
      ),
    );
  }
}
