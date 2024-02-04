import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BookController extends GetxController {
  late var _database;
  RxString resultSearch = 'No Result'.obs;
  RxString resultSearchScan = 'No Result'.obs;

  @override
  Future<void> onInit() async {
    await openDatabaseConnection();
    super.onInit();
  }

  Future<void> openDatabaseConnection() async {
    //New Database
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "localbooks.db");
    await deleteDatabase(path);
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}
    ByteData data = await rootBundle.load(join("assets", "books1.db"));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
    // Open the database
    _database = await openDatabase(path, readOnly: true);
  }

  Future<void> findFromBarcode(String barcode) async {
    await openDatabaseConnection();
    List<Map<String, dynamic>> result = await _database
        .rawQuery("SELECT * FROM books WHERE BARCODE = '$barcode' ");
    result.forEach((row) {
      print(row);
    });

    if (result.isNotEmpty) {
      // Get the first result
      Map<String, dynamic> firstResult = result.first;
      // Access the value of a specific column (replace 'columnName' with the actual column name)
      String firstValue = firstResult['TITLE'];
      // Store the result in the 'result' variable
      // result.value = firstValue;
      resultSearch.value = firstValue;
      print(resultSearch.value);
      //resultSearchScan.value = firstValue;
      print("FirstValue");
      // print(resultSearch.value+"Test");
    }
  }
}
