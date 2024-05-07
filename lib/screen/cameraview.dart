import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_scan/controller/bookcontroller.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:qr_scan/controller/scannercontroller.dart';
import 'package:qr_scan/screen/historyview.dart';
import 'package:qr_scan/screen/navbar.dart';
import 'package:native_barcode_scanner/barcode_scanner.dart';

class CameraView extends StatelessWidget {
  final ScannerController scannercontroller = Get.put(ScannerController());
  final TextEditingController textEditingController = TextEditingController();
  final BookController bookController = Get.put(BookController());
  final scanDBhelper scandbhelper = Get.put(scanDBhelper());
  final scanDBhelper checkedbookcontroller = Get.put(scanDBhelper());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สแกน'),
      ),
      // drawer: MyDrawer(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: BarcodeScannerWidget(
                    onBarcodeDetected: (barcode) async {
                      String myscan = barcode.value;
                      if (scandbhelper.checkDuplicateBook(myscan)) {
                        bookController.showDuplicateSnackbar();
                      } else {
                        await bookController.findFromBarcode(myscan);
                      }
                      await Future.delayed(const Duration(seconds: 2));
                      BarcodeScanner.startScanner();
                    },
                    onError: (error) {
                      // Handle any errors that occur during scanning
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
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
    );
  }
}
