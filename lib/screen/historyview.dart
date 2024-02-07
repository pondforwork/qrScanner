import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/bookcontroller.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:qr_scan/controller/scannercontroller.dart';

class HistoryView extends StatelessWidget {
  HistoryView({Key? key}) : super(key: key);
  final ScannerController scannercontroller = Get.put(ScannerController());
  final BookController bookController = Get.put(BookController());
  final scanDBhelper checkedbookcontroller = Get.put(scanDBhelper());

  @override
  Widget build(BuildContext context) {
    Get.put(BookController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("History and Export"),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_rounded),
            onPressed: () {
              checkedbookcontroller.exportToCSV();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GetX<scanDBhelper>(
                builder: (controller) {
                  return ListView.builder(
                    itemCount: controller.todo.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          print("Click On ${controller.todo[index].title} ");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              ExpansionTile(
                                title: Text(
                                  controller.todo[index].title.length <= 50
                                      ? controller.todo[index].title
                                      : '${controller.todo[index].title.substring(0, 50)}...',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${controller.todo[index].barcode}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: controller.todo[index].found == "Y"
                                    ? Image.asset(
                                        'assets/images/correct.png', // Replace with the actual path to the check image
                                        width: 50, // Set the width as needed
                                        height: 50, // Set the height as needed
                                      )
                                    : Image.asset(
                                        'assets/images/incorrect.png', // Replace with the actual path to the close image
                                        width: 50, // Set the width as needed
                                        height: 50, // Set the height as needed
                                      ),
                                children: [
                                  ListTile(
                                    title: Text(
                                      'ชื่อหนังสือ : ${controller.todo[index].title}',
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      'รหัสหนังสือ : ${controller.todo[index].barcode}',
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      'ผู้สแกน : ยังไม่มี',
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      'หมายเหตุ : ยังไม่มี',
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.more_horiz),
                              const SizedBox(height: 5,)
                            ],
                            
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
