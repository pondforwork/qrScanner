import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BookController extends GetxController {
  @override
  Future<void> onInit() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "books.db");
    await deleteDatabase(path);
    // Make sure the parent directory exists
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    ByteData data = await rootBundle.load(url.join("assets", "books1.db"));

    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await new File(path).writeAsBytes(bytes, flush: true);

    // open the database
    var db = await openDatabase(path, readOnly: true);
    db.rawQuery("SELECT * FROM books WHERE BARCODE = '32498004996862' ");

    List<Map<String, dynamic>> result = await db
        .rawQuery("SELECT * FROM books WHERE COLLECTIONID = '32498004996862' ");

    // print the result to the console
    result.forEach((row) {
      print(row);
    });
    super.onInit();
  }
}
