import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:sqflite/sqflite.dart';

class BookController extends GetxController {
  late Database _database;

  @override
  void onInit() async {
    try {
      _database = await openDatabase('book.db',version: 3); // Replace with your database name
      print("Database opened");

      // ... Perform database operations

    } catch (error) {
      print("Error opening database: $error");
    }
    _database.rawQuery("SELECT * FROM books");
    super.onInit();
  }

  // Example raw query method
  Future<List<Map<String, dynamic>>> customQuery(String sql) async {
    return await _database.rawQuery(sql);
  }

  // Example method to close the database
  Future<void> closeDatabase() async {
    await _database.close();
    print("Database closed");
  }
}
