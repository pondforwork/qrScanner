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
        title: const Text("ประวัติการบันทึก"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.archive_rounded,
              color: Colors.white,
            ),
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
                        onLongPress: () {
                          print(controller.todo[index].barcode);
                          Get.defaultDialog(
                            title: 'ลบหนังสือเล่มนี้',
                            content: Text(
                                "ต้องการลบ ${controller.todo[index].title} หรือไม่"),
                            confirm: ElevatedButton(
                              child: Text(
                                'ตกลง',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                  // fixedSize: Size(200, 40),
                                  textStyle: const TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.normal),
                                  backgroundColor: Colors.red),
                              onPressed: () async {
                                await checkedbookcontroller
                                    .deleteData(controller.todo[index].barcode);
                                Get.back();
                              },
                            ),
                            cancel: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  // fixedSize: Size(200, 40),
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontStyle: FontStyle.normal,
                                  ),
                                  backgroundColor: Colors.green),
                              onPressed: () {
                                Get.back();
                              },
                              child: Text(
                                'ยกเลิก',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
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
                                        'assets/images/correct.png',
                                        width: 50,
                                        height: 50,
                                      )
                                    : Image.asset(
                                        'assets/images/incorrect.png',
                                        width: 50,
                                        height: 50,
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
                                      'ผู้บันทึก : ${controller.todo[index].recorder}',
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      'หมายเหตุ : ${controller.todo[index].note}',
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      'วันเวลาที่บันทึก : ${controller.todo[index].checktime.day.toString().padLeft(2, '0')}'
                                      '/${controller.todo[index].checktime.month.toString().padLeft(2, '0')}'
                                      '/${controller.todo[index].checktime.year} '
                                      '${controller.todo[index].checktime.hour.toString().padLeft(2, '0')}'
                                      ':${controller.todo[index].checktime.minute.toString().padLeft(2, '0')}'
                                      ':${controller.todo[index].checktime.second.toString().padLeft(2, '0')}',
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.more_horiz),
                              const SizedBox(
                                height: 5,
                              )
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
