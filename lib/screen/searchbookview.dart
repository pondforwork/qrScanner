import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/bookcontroller.dart';
import 'package:qr_scan/controller/categorycontroller.dart';
import 'package:qr_scan/controller/scannercontroller.dart';

class SearchBookView extends StatelessWidget {
  SearchBookView({Key? key}) : super(key: key);
  final _barcodefieldcontroller = TextEditingController();
  final ScannerController scannercontroller = Get.put(ScannerController());
  final BookController bookController = Get.put(BookController());

  @override
  Widget build(BuildContext context) {
    Get.put(CategoryController());
    Get.put(BookController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Book"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            Expanded(
              child: TextField(
                controller: _barcodefieldcontroller,
                onSubmitted: (String value) async {
                  bookController.findFromBarcode(_barcodefieldcontroller.text);
                },
              ),
            ),
            Expanded(
              child: Obx(() {
                return Text(bookController.resultSearch.value);
              }),
            ),
           
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   scannercontroller.scanBarcode();

      //   // ScannerController().barcodeResult();
      // }),
    );
  }
}
