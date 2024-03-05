import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:qr_scan/models/chekedbook.dart';
import 'package:share_plus/share_plus.dart';

class scanDBhelper extends GetxController {
  RxString currentdb = 'No Database Selected'.obs;
  var todo = <Checkedbook>[].obs;
  var finishedtodo = <Checkedbook>[].obs;
  RxInt foundqtyobs = 0.obs;
  RxInt notfoundqtyobs = 0.obs;

  @override
  Future<void> onInit() async {
    await initHive();
    await fetchToDo();
    await getDBName();
    countFoundItems();

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
      await Hive.openBox('checkedbook');
      await Hive.openBox('dbname');
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
            value['recorder'],
            value['recorderemail'],
            value['note'],
            value['checktime'],
            value['exportstatus']));
      }
      allData.sort((a, b) => b.checktime.compareTo(a.checktime));
      todo.assignAll(allData);
    } catch (error) {
      print("Error while accessing data: $error");
    }
    countFoundItems();
  }

  void countFoundItems() {
    int foundqty = 0;
    int notfoundqty = 0;
    for (Checkedbook item in todo) {
      if (item.found == "Y") {
        foundqty++;
      } else {
        notfoundqty++;
      }
    }
    foundqtyobs.value = foundqty;
    notfoundqtyobs.value = notfoundqty;
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
      String found,
      String recorder,
      String recorderemail,
      String note,
      DateTime checktime,
      bool exportstatus) async {
    var data = Hive.box('data');
    // for (int i = 9999999999998999; i < 9999999999999999; i++) {}
    data.put(barcode, {
      'barcode': barcode,
      'callNo': callNo,
      'title': title,
      'collectionName': collectionName,
      'itemStatusName': itemStatusName,
      'collectionId': collectionId,
      'found': found,
      'recorder': recorder,
      'recorderemail': recorderemail,
      'note': note,
      'checktime': checktime,
      'exportstatus':exportstatus
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
    fetchToDo();
    print("Clear Data SUccess");
  }

  Future<void> exportToCSV() async {
    DateTime date = DateTime.now();
    String dateformat = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);

    String filename = "Export ${dateformat}";
    try {
      final downloadsDirectory = await getDownloadsDirectory();
      final file = File('${downloadsDirectory!.path}/${filename}.csv');
      final sink = file.openWrite();
      sink.writeln(
          'Barcode,CallNo,Title,CollectionName,ItemStatusName,CollectionId,Found,Recorder,Recorder-Email,Note,CheckTime');

      for (Checkedbook item in todo) {
        String formattedDate =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(item.checktime);
        String escapedTitle = item.title?.replaceAll('"', '""') ?? '';
        sink.writeln(
          '"${item.barcode ?? ''}","${item.callNo ?? ''}","$escapedTitle","${item.collectionName ?? ''}","${item.itemStatusName ?? ''}","${item.collectionId ?? ''}","${item.found ?? ''}","${item.recorder ?? ''}","${item.recorderemail ?? ''}","${item.note}","$formattedDate"',
        );
      }
      await sink.flush();
      await sink.close();
     
      try {
        var shareResult = await Share.shareFilesWithResult(
          ['${downloadsDirectory.path}/${filename}.csv'],
          text: 'Share File Success:',
        );
        if (shareResult.status == ShareResultStatus.success) {
          print('Thank you for sharing the picture!');
        } else {
          print("Share Fail");
        }

      } catch (error) {
        print('Error exporting data to CSV: $error');
      }
    } catch (error) {
      print('Error exporting data to CSV: $error');
    }
  }
}
