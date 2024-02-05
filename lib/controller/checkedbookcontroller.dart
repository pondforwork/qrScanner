import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../models/chekedbook.dart';

// @HiveType(typeId: 0)
// class Checkedbook extends HiveObject {
//   @HiveField(0)
//   late String barcode;

//   @HiveField(1)
//   late String callNo;

//   @HiveField(2)
//   late String title;

//   @HiveField(3)
//   late String collectionName;

//   @HiveField(4)
//   late String itemStatusName;

//   @HiveField(5)
//   late String collectionId;

//   @HiveField(6)
//   late int found;
// }

class DatabaseHelper {
  
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() {
    return _instance;
  }
  DatabaseHelper._internal();
  String boxName = 'checkedbook';
  Future<void> initDatabase() async { 
    final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  // Hive.registerAdapter(ChekedbookAdapter());
    await Hive.openBox<Checkedbook>(boxName);
    
  }

  Box<Checkedbook> get box => Hive.box<Checkedbook>(boxName);

  Future<void> closeDatabase() async {
    await Hive.close();
  }

  Future<void> insertData(Checkedbook data) async {
    await box.add(data);
  }

  Future<void> updateData(int index, Checkedbook newData) async {
    await box.putAt(index, newData);
  }

  Future<void> deleteData(int index) async {
    await box.deleteAt(index);
  }

  List<Checkedbook> getAllData() {
    return box.values.toList();
  }
}
