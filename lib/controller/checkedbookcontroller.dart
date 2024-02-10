import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_file_plus/open_file_plus.dart';
//import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:qr_scan/models/chekedbook.dart';

class scanDBhelper extends GetxController {
  RxString currentdb = 'No Database Selected'.obs;
  var todo = <Checkedbook>[].obs;
  var finishedtodo = <Checkedbook>[].obs;
  @override
  Future<void> onInit() async {
    await initHive();
    await fetchToDo();
    await getDBName();

    super.onInit();
  }

  addToDo(Checkedbook checkedbook) {
    todo.add(checkedbook);
    fetchToDo();
  }

  Future<void> initHive() async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    try {
      await Hive.initFlutter(documentDirectory.path);
      // Hive.registerAdapter(ColorAdapter());
      await Hive.openBox('checkedbook');
      await Hive.openBox('dbname');
      // await clearData();
    } catch (error) {
      print("Hive initialization error: $error");
    }
  }

  Future<void> fetchToDo() async {
    try {
      final documentDirectory = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(documentDirectory.path);
      await Hive.openBox('data');
      var data = Hive.box('data');
      List<dynamic> values = data.values.toList();
      List<Checkedbook> allData = [];

      for (dynamic value in values) {
        allData.add(Checkedbook(
          value['barcode'],
          value['callNo'],
          value['title'],
          value['collectionName'],
          value['itemStatusName'],
          value['collectionId'],
          value['found'],
        ));
      }
      print(allData);
      // Sort the list by the "order" property
      allData.sort((a, b) => a.barcode.compareTo(b.barcode));
      todo.assignAll(allData);
    } catch (error) {
      print("Error while accessing data: $error");
    }
  }

  Future<void> setDBName(String name) async {
    try {
      var dbstatus = Hive.box('dbname');
      await dbstatus.put('DatabaseName', {'dbname': name});
    } catch (error) {
      print('Error setting database name: $error');
    }
  }

  Future<void> getDBName() async {
    try {
      var dbstatus = Hive.box('dbname');
      // Assuming 'DatabaseName' is the key under which the database name is stored
      List<dynamic> values = dbstatus.values.toList();
      List<String> allData = [];
      for (dynamic value in values) {
        allData.add(value['dbname']);
      }
      currentdb.value = allData[0];
      print(allData);
      // Sort the list by the "order" property
    } catch (error) {
      print('Error getting database name: $error');
    }
  }

  Future<void> clearDBNameBox() async {
    try {
      var dbstatus = Hive.box('dbname');
      // Delete all data in the 'dbname' box
      await dbstatus.clear();
      print('All data in the "dbname" box deleted.');
    } catch (error) {
      print('Error clearing "dbname" box: $error');
    }
  }

  Future<void> addData(
      String barcode,
      String callNo,
      String title,
      String collectionName,
      String itemStatusName,
      int collectionId,
      String found) async {
    var data = Hive.box('data');
    data.put(barcode, {
      'barcode': barcode,
      'callNo': callNo,
      'title': title,
      'collectionName': collectionName,
      'itemStatusName': itemStatusName,
      'collectionId': collectionId,
      'found': found,
    });
    fetchToDo();
  }

  Future<void> deleteData(String id) async {
    var data = Hive.box('data');
    if (data.containsKey(id)) {
      await data.delete(id);
      fetchToDo();
    } else {
      print('Data with ID $id not found.');
    }
  }

  Future<void> clearData() async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(documentDirectory.path);
    await Hive.openBox('data');
    var data = Hive.box('data');
    await data.clear();
    fetchToDo(); // Refresh the list after clearing data
    print("Clear Data SUccess");
  }

  Future<void> exportToCSV() async {
    try {
      final downloadsDirectory = await getDownloadsDirectory();
      final docDirectory = await getApplicationDocumentsDirectory();
      
      final file = File('${downloadsDirectory!.path}/TestExport.csv');
      final sink = file.openWrite();
      sink.writeln(
          'Barcode,CallNo,Title,CollectionName,ItemStatusName,CollectionId,Found');
      for (Checkedbook item in todo) {
        sink.writeln(
          '"${item.barcode}","${item.callNo}","${item.title}","${item.collectionName}","${item.itemStatusName}","${item.collectionId}","${item.found}"',
        );
      }
      await sink.flush();
      await sink.close();
      print('Data exported to CSV file: ${file.path}');
      print('${downloadsDirectory.path}/TestExport.csv');
      //OpenFile.open('${downloadsDirectory.path}');
      OpenFile.open('${downloadsDirectory.path}/TestExport.csv');
    } catch (error) {
      print('Error exporting data to CSV: $error');
    }
  }
}
