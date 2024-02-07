import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:qr_scan/models/chekedbook.dart';
import 'package:sqflite/sqflite.dart';

class BookController extends GetxController {
  Database? _database;
  RxString resultSearch = 'No Result'.obs;
  RxString resultsearchonDialog = 'No Result'.obs;

  RxBool isLoading = false.obs; // Observable for tracking loading state
  final scanDBhelper scandbhelper = Get.put(scanDBhelper());

  @override
  Future<void> onInit() async {
    await _openLocalDatabase();
    super.onInit();
  }

  Future<void> openDatabaseConnection() async {
    // Let the user choose a file using a file picker
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      // Selected file
      PlatformFile file = result.files.first;
      //Set Current DatabaseName
      scandbhelper.currentdb.value = file.name;
      scandbhelper.setDBName(file.name);

      // New Database
      var databasesPath = await getDatabasesPath();
      var path = join(databasesPath, "localbooks.db");

      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Read data from the selected file
      List<int> bytes = await File(file.path ?? "").readAsBytes();

      // Write data to localbooks.db
      await File(path).writeAsBytes(bytes, flush: true);

      // Open the database
      await _openLocalDatabase();
    }
  }

  Future<void> _openLocalDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "localbooks.db");
    _database = await openDatabase(path, readOnly: false);
  }

  //THIS IS FIND FROM CLICK SEARCH
  Future<void> findFromBarcode(String barcode) async {
    if (scandbhelper.currentdb.value != "No Database Selected") {
      await _openLocalDatabase();
      isLoading.value = true; // Loading

      List<Map<String, dynamic>> result = await _database!
          .rawQuery("SELECT * FROM books WHERE BARCODE = '$barcode' ");
      result.forEach((row) {});
      isLoading.value = false; // Load Finish

      if (result.isNotEmpty) {
        Map<String, dynamic> firstResult = result.first;
        String firstValue = firstResult['TITLE'];
        resultSearch.value = firstValue;
        Get.defaultDialog(
          title: "Result",
          content: Text("Book Name : $firstValue"),
          actions: [
            TextButton(
              onPressed: () async {
                Get.back(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            const SizedBox(
              width: 50,
            ),
            TextButton(
              onPressed: () async {
                Checkedbook checkedbook = Checkedbook(
                  firstResult['BARCODE'],
                  firstResult['CALLNO'],
                  firstResult['TITLE'],
                  firstResult['COLLECTIONNAME'],
                  firstResult['ITEMSTATUSNAME'],
                  firstResult['COLLECTIONID'],
                  "Y",
                );
                scandbhelper.addData(
                    checkedbook.barcode,
                    checkedbook.callNo,
                    checkedbook.title,
                    checkedbook.collectionName,
                    checkedbook.itemStatusName,
                    checkedbook.collectionId,
                    checkedbook.found);
                scandbhelper.fetchToDo();
                Get.back(); // Close the dialog
              },
              child: const Text("Add"),
            ),
          ],
        );
      } else {
        resultSearch.value = "No result";
        Get.defaultDialog(
          title: "Search Result",
          content: const Text("No Result"),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      }
    } else {
      print("Select DB First");
    }
  }
}
