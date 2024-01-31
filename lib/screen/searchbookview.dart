import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/bookcontroller.dart';
import 'package:qr_scan/controller/categorycontroller.dart';
import 'package:qr_scan/controller/productcontroller.dart';
import 'package:qr_scan/controller/scannercontroller.dart';

class SearchBookView extends StatelessWidget {
  SearchBookView({Key? key}) : super(key: key);
  var _Barcodecontroller = TextEditingController();
  final ScannerController scannercontroller = Get.put(ScannerController());

  @override
  Widget build(BuildContext context) {
    Get.put(CategoryController());
    Get.put(ProductController());
    Get.put(BookController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Book"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Expanded(
              child: TextField(
                controller: _Barcodecontroller,
                onSubmitted: (String value) async {
                  BookController().findFromBarcode(_Barcodecontroller.text);
                },
              ),
            ),
            Expanded(
              child: Text("Result"),
            ),
            Expanded(
              child: Text(ScannerController().barcodeResult()),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        scannercontroller.scanBarcode();

        // ScannerController().barcodeResult();
      }),
    );
  }
}
