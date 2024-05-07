import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:qr_scan/models/chekedbook.dart';
import 'package:share_plus/share_plus.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class scanDBhelper extends GetxController {
  RxString currentdb = 'No Database Selected'.obs;
  var todo = <Checkedbook>[].obs;
  RxInt foundqtyobs = 0.obs;
  RxInt notfoundqtyobs = 0.obs;
  RxBool exportStatus = false.obs;
  RxInt allunexportedQty = 0.obs;
  RxInt indexCount = 0.obs;
  RxInt exportProgress = 0.obs;

  @override
  Future<void> onInit() async {
    await initHive();
    await fetchToDo();
    await getDBName();
    countFoundItems();
    checkExportStatus(todo);
    super.onInit();
  }

  // addToDo(Checkedbook checkedbook) async {
  //   todo.add(checkedbook);
  //   await fetchToDo();
  //   checkExportStatus(todo);
  // }

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
            value['author'],
            value['collectionName'],
            value['itemStatusName'],
            value['collectionId'],
            value['found'],
            value['recorder'],
            value['recorderemail'],
            value['note'],
            value['checktime'],
            value['count'],
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

  Future<void> resetDBName() async {
    try {
      var dbstatus = Hive.box('dbname');
      await dbstatus.put('DatabaseName', {'dbname': "No Database Selected"});
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
      String author,
      String collectionName,
      String itemStatusName,
      int collectionId,
      String found,
      String recorder,
      String recorderemail,
      String note,
      DateTime checktime,
      int count,
      bool exportstatus) async {
    var data = Hive.box('data');
    int countFromList = countDuplicate(barcode);
    if (countFromList >= 1) {
      count = countFromList + 1;
    } else {
      count = 1;
    }

    data.put(barcode, {
      'barcode': barcode,
      'callNo': callNo,
      'title': title,
      'author': author,
      'collectionName': collectionName,
      'itemStatusName': itemStatusName,
      'collectionId': collectionId,
      'found': found,
      'recorder': recorder,
      'recorderemail': recorderemail,
      'note': note,
      'checktime': checktime,
      'count': count,
      'exportstatus': exportstatus
    });
    showSavedBookSnackbar(title);
    fetchToDo();
    exportStatus.value = false;
  }

  showSavedBookSnackbar(String title) {
    Get.snackbar(
      'บันทึกสำเร็จ',
      'ชื่อหนังสือ : $title',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color.fromARGB(
          255, 255, 249, 171), // Custom1ize the background color here
      duration: const Duration(seconds: 3),
    );
  }

  bool checkExportStatus(List<Checkedbook> todo) {
    for (var i = 0; i < todo.length; i++) {
      if (todo[i].exportstatus == false) {
        print((todo[i].exportstatus));
        exportStatus.value = false;
        return false;
      }
    }
    exportStatus.value = true;
    return true;
  }

  updateExportStatus() {
    for (var i = 0; i < todo.length; i++) {
      print(todo[i].barcode);
      var data = Hive.box('data');
      data.put(todo[i].barcode, {
        'barcode': todo[i].barcode,
        'callNo': todo[i].callNo,
        'title': todo[i].title,
        'author': todo[i].author,
        'collectionName': todo[i].collectionName,
        'itemStatusName': todo[i].itemStatusName,
        'collectionId': todo[i].collectionId,
        'found': todo[i].found,
        'recorder': todo[i].recorder,
        'recorderemail': todo[i].recorderemail,
        'note': todo[i].note,
        'checktime': todo[i].checktime,
        'count': todo[i].count,
        'exportstatus': true
      });
    }
    fetchToDo();
  }

  updateExportStatusByOne(int i) {
    var data = Hive.box('data');

    data.put(todo[i].barcode, {
      'barcode': todo[i].barcode,
      'callNo': todo[i].callNo,
      'title': todo[i].title,
      'author': todo[i].author,
      'collectionName': todo[i].collectionName,
      'itemStatusName': todo[i].itemStatusName,
      'collectionId': todo[i].collectionId,
      'found': todo[i].found,
      'recorder': todo[i].recorder,
      'recorderemail': todo[i].recorderemail,
      'note': todo[i].note,
      'checktime': todo[i].checktime,
      'count': todo[i].count,
      'exportstatus': true
    });
    print("Updating ${todo[i].title}");

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
          'Barcode,CallNo,Title,Author,CollectionName,ItemStatusName,CollectionId,Found,Count,Recorder,Recorder-Email,Note,CheckTime');

      for (Checkedbook item in todo) {
        String formattedDate =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(item.checktime);
        String escapedTitle = item.title?.replaceAll('"', '""') ?? '';
        sink.writeln(
          '"${item.barcode ?? ''}","${item.callNo ?? ''}","$escapedTitle","${item.author ?? ''}","${item.collectionName ?? ''}","${item.itemStatusName ?? ''}","${item.collectionId ?? ''}","${item.found ?? ''}","${item.count}","${item.recorder ?? ''}","${item.recorderemail ?? ''}","${item.note}","$formattedDate"',
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
          // updateExportStatus();
          // checkExportStatus(todo);
          exportStatus.value = true;
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

  Future<bool> sendPostRequest(String url, Map<String, dynamic> data) async {
    try {
      String jsonData = jsonEncode(data);
      http.Response response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );
      if (response.statusCode == 200) {
        print('POST request successful');
        print('Response: ${response.body}');
      } else {
        print('Failed to send POST request');
        print('Response: ${response.body}');
      }
      return false;
    } catch (e) {
      print('Error sending POST request: $e');
      return true;
    }
  }

  int checkunexportQty() {
    allunexportedQty.value = 0;
    for (Checkedbook item in todo) {
      if (!item.exportstatus) {
        allunexportedQty.value++;
      }
    }
    return allunexportedQty.value;
  }

  Future<void> showDialogExport() async {
    checkunexportQty();
    if (allunexportedQty.value == 0) {
      Get.defaultDialog(
        title: "ไม่มีข้อมูล",
        content: const Text("ไม่สามารถส่งออกได้โดยที่ยังไม่ได้บันทึกข้อมูล"),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("ตกลง"),
          ),
        ],
      );
    } else {
      Get.defaultDialog(
        title: "ต้องการส่งออกข้อมูลหรือไม่?",
        content: Obx(() =>
            Text("จำนวนทั้งหมด ${allunexportedQty.value.toString()} เล่ม")),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("ยกเลิก"),
          ),
          const SizedBox(width: 50),
          TextButton(
            onPressed: () {
              Get.back();
              showProgressDialog();
            },
            child: const Text("ตกลง"),
          ),
        ],
      );
    }
  }

  showProgressDialog() async {
    Get.defaultDialog(
      title: "กำลังส่งข้อมูล...",
      content: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 15), // Add space between items
              Text("${exportProgress.value} จาก ${allunexportedQty.value} ")
            ],
          )),
    );
    exportToApi();
    // if (exportProgress.value == allunexportedQty.value) {
    //   Get.back();
    //   Get.defaultDialog(
    //     title: "ส่งออกข้อมูลสำเร็จ",
    //     middleText: "ส่งออกข้อมูลเรียบร้อยแล้ว",
    //     actions: [
    //       TextButton(
    //         onPressed: () {
    //           Get.back();
    //         },
    //         child: const Text("ตกลง"),
    //       ),
    //     ],
    //   );
    // }
  }

  exportToApi() async {
    String url =
        'http://pulinet2019.buu.ac.th/inventorybook/InsertInventorybook';

    indexCount.value = 0;
    exportProgress.value = 0;

    for (Checkedbook item in todo) {
      String formattedDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(item.checktime);
      if (!item.exportstatus) {
        Map<String, dynamic> postData = {
          "Barcode": item.barcode,
          "CallNo": item.callNo,
          "Title": item.title,
          "Author": null,
          "CollectionName": item.collectionName,
          "ItemStatusName": item.itemStatusName,
          "CollectionId": item.collectionId.toString(),
          "Status": item.found,
          "Staff": item.recorder,
          "StaffEmail": item.recorderemail,
          "Note": item.note,
          "CheckTime": formattedDate,
          "Count": item.count
        };
        exportProgress.value++;
        //if Error Get Back and break loop.
        if (await sendPostRequest(url, postData)) {
          Get.back();
          showerrorDialog();
          break;
        } else {
          updateExportStatusByOne(indexCount.value);
          print("Index");
          print(indexCount.value);
          print("Progress");
          print(exportProgress.value);
        }
      }
      indexCount.value++;
    }
    if (exportProgress.value == allunexportedQty.value) {
      Get.back();
      showFinishExportDialog();
    }
  }

  void showerrorDialog() {
    Get.defaultDialog(
      title: "เกิดข้อผิดพลาด",
      content: const SizedBox(
        width: 150,
        height: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("ไม่สามารถส่งออกข้อมูล"),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("ตกลง"),
        ),
      ],
    );
  }

  void showFinishExportDialog() {
    Get.snackbar(
      'ส่งออกข้อมูลเรียบร้อยแล้ว', // Title
      '', // Message
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  int countDuplicate(String inputbarcode) {
    try {
      var foundCheckedbook =
          todo.firstWhere((checkedBook) => checkedBook.barcode == inputbarcode);
      return foundCheckedbook.count;
    } catch (e) {
      return 0;
    }
  }

  bool checkDuplicateBook(String barcode) {
    for (Checkedbook checkedBook in todo) {
      print("1");
      if (checkedBook.barcode == barcode) {
        print(checkedBook.title);
        return true;
      }
    }
    return false;
  }

  // ใช้ตัวนี้ในการรับค่ามาอัพเดท
  // updateDuplicatebook(String barcode) {
  //   for (Checkedbook checkedBook in todo) {
  //     if (checkedBook.barcode == barcode) {
  //       checkedBook.count = checkedBook.count++;
  //       addData(
  //           barcode,
  //           checkedBook.callNo,
  //           checkedBook.title,
  //           checkedBook.author,
  //           checkedBook.collectionName,
  //           checkedBook.itemStatusName,
  //           checkedBook.collectionId,
  //           checkedBook.found,
  //           checkedBook.recorder,
  //           checkedBook.recorderemail,
  //           checkedBook.note,
  //           checkedBook.checktime,
  //           checkedBook.count,
  //           checkedBook.exportstatus);
  //     }
  //   }
  //   print("Updated");
  // }
}
