import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BookController extends GetxController {
  var db = await openDatabase('my_db.db');

}

