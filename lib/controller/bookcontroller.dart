import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BookController {
  late Database _database;

  Future<void> initializeDatabase() async {
    // Step 1: Copy the database from assets to local storage
    ByteData data = await rootBundle.load("assets/mydatabase.db");
    List<int> bytes = data.buffer.asUint8List();
    String path = join(await getDatabasesPath(), "mydatabase.db");
    await File(path).writeAsBytes(bytes, flush: true);

    // Step 2: Open the database
    _database = await openDatabase(path);

    print("Database opened");

    // Step 3: Perform database operations
    List<Map<String, dynamic>> result = await _database.rawQuery("SELECT * FROM your_table_name");
    print("Query result: $result");

    // Close the database when done
    await _database.close();
    print("Database closed");
  }
}
