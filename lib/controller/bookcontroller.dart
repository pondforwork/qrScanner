import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:qr_scan/controller/usercontroller.dart';
import 'package:qr_scan/models/chekedbook.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class BookController extends GetxController {
  Database? _database;
  RxString resultSearch = 'No Result'.obs;
  RxString resultsearchonDialog = 'No Result'.obs;
  RxBool isLoading = false.obs; // Observable for tracking loading state
  final scanDBhelper scandbhelper = Get.put(scanDBhelper());
  final UserController userController = Get.put(UserController());

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
    if (checkdbAvial() == true) {
      await _openLocalDatabase();
      isLoading.value = true; // Loading
      //await Future.delayed(Duration(seconds: 3));
      List<Map<String, dynamic>> result = await _database!
          .rawQuery("SELECT * FROM books WHERE BARCODE = '$barcode' ");
      result.forEach((row) {});
      isLoading.value = false; // Load Finish

      if (result.isNotEmpty) {
        Map<String, dynamic> firstResult = result.first;
        String firstValue = firstResult['TITLE'];
        showDialogForResult(firstValue, firstResult['TITLE'], firstResult);
      } else {
        resultSearch.value = "No result";
        showDialogNotFound(barcode);
      }
    } else {
      print("Select DB First");
    }
  }

  bool checkdbAvial() {
    if (scandbhelper.currentdb.value != "No Database Selected") {
      //Database Selected
      print("true");
      return true;
    } else {
      //Database Selected
      return false;
    }
  }

  Future<void> showDialogForResult(
      String bookName, String barcode, Map<String, dynamic> firstResult) async {
    String colId = firstResult['COLLECTIONID'].toString();
    Get.defaultDialog(
      title: "Book Found!!!",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Book Name : $bookName"),
          const SizedBox(
            height: 20,
          ),
          Text("Collection Id :  $colId")
        ],
      ),
      actions: [
        SizedBox(
          width: 100,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
            ),
            onPressed: () async {
              Get.back(); // Close the dialog
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(
          width: 50,
        ),
        SizedBox(
          width: 100,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () async {
              DateTime checktime = DateTime.now();

              Checkedbook checkedbook = Checkedbook(
                  firstResult['BARCODE'],
                  firstResult['CALLNO'],
                  firstResult['TITLE'],
                  firstResult['COLLECTIONNAME'],
                  firstResult['ITEMSTATUSNAME'],
                  firstResult['COLLECTIONID'],
                  "Y",
                  userController.currentUser.value,
                  "",
                  checktime);
              scandbhelper.addData(
                  checkedbook.barcode,
                  checkedbook.callNo,
                  checkedbook.title,
                  checkedbook.collectionName,
                  checkedbook.itemStatusName,
                  checkedbook.collectionId,
                  checkedbook.found,
                  checkedbook.recorder,
                  checkedbook.note,
                  checkedbook.checktime);
              scandbhelper.fetchToDo();
              Get.back(); // Close the dialog
            },
            child: const Text(
              "Add",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> showDialogNotFound(String barcode) async {
    TextEditingController titleController = TextEditingController();
    TextEditingController collectionIdController = TextEditingController();
    TextEditingController noteController = TextEditingController();

    Get.defaultDialog(
      title: "Book Not Found!!!",
      content: Column(
        children: [
          Text("BARCODE : $barcode"),
          SizedBox(height: 10),
          Text("Enter Book Information:"),
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: collectionIdController,
            decoration: InputDecoration(labelText: 'Collection ID'),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          TextField(
            controller: noteController,
            decoration: InputDecoration(labelText: 'Note'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Get.back(); // Close the dialog
          },
          child: const Text("Cancel"),
        ),
        const SizedBox(width: 50),
        TextButton(
          onPressed: () async {
            Get.back(); // Close the current dialog

            bool confirmAdd = await Get.defaultDialog(
              title: "Add Missing Book?",
              content: Text("Are you sure you want to add this book?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back(result: false); // Cancel
                  },
                  child: const Text("No"),
                ),
                const SizedBox(width: 50),
                TextButton(
                  onPressed: () {
                    Get.back(result: true); // Confirm
                  },
                  child: const Text("Yes"),
                ),
              ],
            );

            if (confirmAdd == true) {
              DateTime checktime = DateTime.now();

              Checkedbook checkedbook = Checkedbook(
                  barcode,
                  "",
                  titleController.text,
                  "",
                  "",
                  int.parse(collectionIdController.text),
                  "N",
                  userController.currentUser.value,
                  noteController.text,
                  checktime);
              scandbhelper.addData(
                  checkedbook.barcode,
                  checkedbook.callNo,
                  checkedbook.title,
                  checkedbook.collectionName,
                  checkedbook.itemStatusName,
                  checkedbook.collectionId,
                  checkedbook.found,
                  checkedbook.recorder,
                  checkedbook.note,
                  checkedbook.checktime);
              scandbhelper.fetchToDo();
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
