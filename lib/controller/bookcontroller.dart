import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:sqflite/sqflite.dart';

class BookController extends GetxController {
  Database? _database;

  RxString resultSearch = 'No Result'.obs;
  RxString resultsearchonDialog = 'No Result'.obs;
 

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

  Future<void> findFromBarcode(String barcode) async {
    await openDatabaseConnection();
    List<Map<String, dynamic>> result = await _database!
        .rawQuery("SELECT * FROM books WHERE BARCODE = '$barcode' ");
    result.forEach((row) {
      print(row);
    });

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
              Get.back(); // Close the dialog
            },
            child: Text("Create DB"),
          ),
          TextButton(
            onPressed: () {
            
              Get.back(); // Close the dialog
            },
            child: Text("Insert"),
          ),
          TextButton(
            onPressed: () async {
              print('Database path: ${_database!.path}');
              // await _database?.rawQuery('SELECT * FROM books');
             
              Get.back(); // Close the dialog
            },
            child: Text("Print"),
          ),
        ],
      );
    } else {
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
