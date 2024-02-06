import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:qr_scan/models/chekedbook.dart';
import 'package:sqflite/sqflite.dart';

class BookController extends GetxController {
  Database? _database;
  RxString resultSearch = 'No Result'.obs;
  RxString resultsearchonDialog = 'No Result'.obs;
  RxBool isLoading = false.obs; // Observable for tracking loading state
  final scanDBhelper scandbhelper = Get.put(scanDBhelper());

  @override
  Future<void> onInit() async {
    await openDatabaseConnection();
    super.onInit();
  }

  Future<void> openDatabaseConnection() async {
    // New Database
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "localbooks.db");
    // await deleteDatabase(path);
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}
    ByteData data = await rootBundle.load(join("assets", "books1.db"));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
    // Open the database
    _database = await openDatabase(path, readOnly: false);
  }
  //THIS IS FIND FROM CLICK SEARCH
  Future<void> findFromBarcode(String barcode) async {
    await openDatabaseConnection();
    isLoading.value = true; // Loading
    await Future.delayed(Duration(seconds: 2));
    List<Map<String, dynamic>> result = await _database!
        .rawQuery("SELECT * FROM books WHERE BARCODE = '$barcode' ");
    result.forEach((row) {
      print(row);
    });
    isLoading.value = false; // Load Finish

    if (result.isNotEmpty) {
      Map<String, dynamic> firstResult = result.first;
      String firstValue = firstResult['TITLE'];
      resultSearch.value = firstValue;
      Get.defaultDialog(
        title: "Result",
        content: Text("Book Name : $firstValue"),
        actions: [
          TextButton(
            onPressed: () async {
              scandbhelper.fetchToDo();
              Get.back();
            },
            child: Text("Fetch"),
          ),
          TextButton(
            onPressed: () async {
              Checkedbook checkedbook = Checkedbook(
                firstResult['BARCODE'],
                firstResult['CALLNO'],
                firstResult['TITLE'],
                firstResult['COLLECTIONNAME'],
                firstResult['ITEMSTATUSNAME'],
                firstResult['COLLECTIONID'],
                "Y",
              );
              scandbhelper.addData(checkedbook.barcode, checkedbook.callNo, checkedbook.title, checkedbook.collectionName, checkedbook.itemStatusName, checkedbook.collectionId, checkedbook.found);
              scandbhelper.fetchToDo();
              Get.back(); // Close the dialog
            },
            child: Text("Insert"),
          ),
          TextButton(
            onPressed: () async {
              scandbhelper.exportToCSV();
              Get.back(); // Close the dialog
            },
            child: Text("Export CSV"),
          ),
        ],
      );
    } else {
      resultSearch.value = "No result";
      Get.defaultDialog(
        title: "Search Result",
        content: Text("No Result"),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
            },
            child: Text("OK"),
          ),
        ],
      );
    }
  }
}
