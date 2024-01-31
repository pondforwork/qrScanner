import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BookController extends GetxController {
  late var _database;

  @override
  Future<void> onInit() async {
    await openDatabaseConnection(); // Call the method to open the database
    super.onInit();
  }

  Future<void> openDatabaseConnection() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "books.db");

    // Delete the database (optional, depending on your use case)
    await deleteDatabase(path);

    // Make sure the parent directory exists
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
    // Ensure the database is open before querying
    await openDatabaseConnection();
    List<Map<String, dynamic>> result =
        await _database.rawQuery("SELECT * FROM books WHERE BARCODE = '$barcode' ");
    result.forEach((row) {
      print(row);
    });
  }
}
