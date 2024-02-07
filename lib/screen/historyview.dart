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
        title: const Text("History"),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(child: GetX<scanDBhelper>(
            builder: (controller) {
              return ListView.builder(
                  itemCount: controller.todo.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      margin: EdgeInsets.all(12),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.todo[index].title.length <= 50
                                  ? controller.todo[index].title
                                  : '${controller.todo[index].title.substring(0, 50)}...',
                              style: TextStyle(
                                fontSize: 18, // Adjust the font size as needed
                                fontWeight: FontWeight
                                    .bold, // Adjust the font weight as needed
                              ),
                            ),
                            SizedBox(
                                height:
                                    8), // Add some spacing between title and subtitle
                            Text(
                              '${controller.todo[index].barcode}',
                              style: TextStyle(
                                fontSize: 16, // Adjust the font size as needed
                                color: Colors
                                    .grey, // Adjust the text color as needed
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            },
          )),
        ],
      )),
    );
  }
}
