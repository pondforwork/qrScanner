import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:qr_scan/models/chekedbook.dart';
// import 'package:open_file/open_file.dart'; // Import the open_file package


class scanDBhelper extends GetxController {
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

  Future<void> exportToCSV() async {
    try {
      final downloadsDirectory = await getDownloadsDirectory();
      final file = File('${downloadsDirectory!.path}/CheckBook.csv');
      final sink = file.openWrite();

      // Write headers to the CSV file
      sink.writeln('Barcode,CallNo,Title,CollectionName,ItemStatusName,CollectionId,Found');

      // Write todo items to the CSV file
      for (Checkedbook item in todo) {
        sink.writeln(
          '${item.barcode},${item.callNo},${item.title},${item.collectionName},${item.itemStatusName},${item.collectionId},${item.found}',
        );
      }

      await sink.flush();
      await sink.close();
      // openDirectory();
      print('Data exported to CSV file: ${file.path}');
    } catch (error) {
      print('Error exporting data to CSV: $error');
    }
  }

  // Future<void> openDirectory() async {
  //   try {
  //     final downloadsDirectory = await getDownloadsDirectory();
  //     if (downloadsDirectory != null) {
  //       await OpenFile.open(downloadsDirectory.path);
  //     } else {
  //       print('Downloads directory not found.');
  //     }
  //   } catch (error) {
  //     print('Error opening directory: $error');
  //   }
  // }

}
