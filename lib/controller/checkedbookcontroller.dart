import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// import 'package:csv/csv.dart';
import 'package:qr_scan/models/chekedbook.dart';

class ToDoController extends GetxController {
  var todo = <Checkedbook>[].obs;
  var finishedtodo = <Checkedbook>[].obs;
  @override
  void onInit() {
    initHive();
    fetchToDo();
    // fetchFinishedToDo();
    // clearData();
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

  // Future<void> exportToCSV() async {
  //   try {
  //     final documentDirectory = await getApplicationDocumentsDirectory();
  //     final file = File('${documentDirectory.path}/todo_data.csv');
  //     final sink = file.openWrite();

  //     // Write headers to the CSV file
  //     sink.write('ID,Topic,IsFinish,Color,Order\n');

  //     // Write todo items to the CSV file
  //     for (Checkedbook item in todo) {
  //       sink.write(
  //           '${item.id},"${item.topic}",${item.isfinish},"${item.color.value}",${item.order.toIso8601String()}\n');
  //     }

  //     await sink.flush();
  //     await sink.close();

  //     print('Data exported to CSV file: ${file.path}');
  //   } catch (error) {
  //     print('Error exporting data to CSV: $error');
  //   }
  // }
}
