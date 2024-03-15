import 'dart:io';
import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:qr_scan/controller/usercontroller.dart';
import 'package:qr_scan/models/chekedbook.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_archive/flutter_archive.dart';

class BookController extends GetxController {
  Database? _database;
  RxString resultSearch = 'No Result'.obs;
  RxString resultsearchonDialog = 'No Result'.obs;
  RxBool isLoading = false.obs;
  RxBool isDownloadingDB = false.obs;
  final scanDBhelper scandbhelper = Get.put(scanDBhelper());
  final UserController userController = Get.put(UserController());
  RxString loadingprogress = "0.0".obs;
  RxString downloadedPath = "".obs;
  RxBool unzippingstatus = false.obs;
  String filePathZip = "/storage/emulated/0/Download/Books.zip";

  @override
  Future<void> onInit() async {
    await _openLocalDatabase();
    isDownloadingDB.value = false;
    super.onInit();
  }

  Future<void> openDatabaseConnectionWithPath(String downloadedfilepath) async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "localbooks.db");

    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}
    List<int> bytes = await File(downloadedfilepath).readAsBytes();
    scandbhelper.currentdb.value = downloadedfilepath;
    scandbhelper.setDBName(downloadedfilepath);
    // Write data to localbooks.db
    await File(path).writeAsBytes(bytes, flush: true);
    // Open the database
    await _openLocalDatabase();
    clearTempFiles();
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
      isLoading.value = true;
      List<Map<String, dynamic>> result = await _database!
          .rawQuery("SELECT * FROM books WHERE BARCODE = '$barcode' ");
      result.forEach((row) {});
      isLoading.value = false;
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
      return true;
    } else {
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
              Get.back();
            },
            child: const Text(
              "ยกเลิก",
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
              // First Save
              Checkedbook checkedbook = Checkedbook(
                  firstResult['BARCODE'] ?? "",
                  firstResult['CALLNO'] ?? "",
                  firstResult['TITLE'] ?? "",
                  firstResult['COLLECTIONNAME'] ?? "",
                  firstResult['ITEMSTATUSNAME'] ?? "",
                  firstResult['COLLECTIONID'] ?? "",
                  "Y",
                  userController.currentUser.value,
                  userController.currentUserEmail.value,
                  "",
                  checktime,
                  1,
                  false);
              scandbhelper.addData(
                  checkedbook.barcode,
                  checkedbook.callNo,
                  checkedbook.title,
                  checkedbook.collectionName,
                  checkedbook.itemStatusName,
                  checkedbook.collectionId,
                  checkedbook.found,
                  checkedbook.recorder,
                  checkedbook.recorderemail,
                  checkedbook.note,
                  checkedbook.checktime,
                  checkedbook.count,
                  checkedbook.exportstatus);
              scandbhelper.fetchToDo();
              Get.back(); // Close the dialog
            },
            child: const Text(
              "บันทึก",
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
    TextEditingController callNocontroller = TextEditingController();
    TextEditingController authorController = TextEditingController();

    TextEditingController noteController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    Get.defaultDialog(
      title: "ไม่พบหนังสือ",
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text("ใส่ข้อมูลหนังสือด้านล่าง"),
            const SizedBox(height: 20),
            Text(
              "BARCODE : $barcode",
              style: TextStyle(fontSize: 17),
            ),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาใส่ชื่อหนังสือ';
                }
                return null;
              },
            ),
            TextFormField(
              controller: callNocontroller,
              decoration: InputDecoration(labelText: 'Call No.'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาใส่เลขเรียก';
                }
                return null;
              },
            ),
            TextFormField(
              controller: noteController,
              decoration: InputDecoration(labelText: 'Note'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Get.back(); // Close the dialog
          },
          child: const Text("ยกเลิก"),
        ),
        const SizedBox(width: 50),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              // Form is valid, proceed with the action

              Get.back(); // Close the current dialog

              bool confirmAdd = await Get.defaultDialog(
                title: "เพิ่มหนังสือเกิน?",
                content: const Text("คุณต้องการเพิ่มหนังสือเล่มนี้หรือไม่?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back(result: false); // Cancel
                    },
                    child: const Text("ยกเลิก"),
                  ),
                  const SizedBox(width: 50),
                  TextButton(
                    onPressed: () {
                      Get.back(result: true); // Confirm
                    },
                    child: const Text("ตกลง"),
                  ),
                ],
              );

              if (confirmAdd == true) {
                DateTime checktime = DateTime.now();
                Checkedbook checkedbook = Checkedbook(
                    barcode,
                    callNocontroller.text,
                    titleController.text,
                    "",
                    "",
                    0,
                    "N",
                    userController.currentUser.value,
                    userController.currentUserEmail.value,
                    noteController.text,
                    checktime,
                    1,
                    false);
                scandbhelper.addData(
                    checkedbook.barcode,
                    checkedbook.callNo,
                    checkedbook.title,
                    checkedbook.collectionName,
                    checkedbook.itemStatusName,
                    checkedbook.collectionId,
                    checkedbook.found,
                    checkedbook.recorder,
                    checkedbook.recorderemail,
                    checkedbook.note,
                    checkedbook.checktime,
                    checkedbook.count,
                    checkedbook.exportstatus);
                scandbhelper.fetchToDo();
              }
            }
          },
          child: const Text("ตกลง"),
        ),
      ],
    );
  }

  downloadFile() async {
    await requestStoragePermission();
    isDownloadingDB.value = true;
    if (await File(filePathZip).exists()) {
      try {
        await File(filePathZip).delete();
        await FileDownloader.downloadFile(
          url: "https://platform.buu.in.th/downloads/BooksZip.zip",
          name: "Books",
          downloadDestination: DownloadDestinations.publicDownloads,
          onProgress: (String? name, double progress) {
            loadingprogress.value = progress.toString();
            print('FILE fileName HAS PROGRESS $progress');
          },
          onDownloadCompleted: (String path) {
            downloadedPath.value = path;
          },
          onDownloadError: (String error) {},
        );
      } catch (e) {
        print(e);
      }
    } else {
      await FileDownloader.downloadFile(
        url: "https://platform.buu.in.th/downloads/BooksZip.zip",
        name: "Books",
        downloadDestination: DownloadDestinations.publicDownloads,
        onProgress: (String? name, double progress) {
          loadingprogress.value = progress.toString();
          print('FILE fileName HAS PROGRESS $progress');
        },
        onDownloadCompleted: (String path) {
          downloadedPath.value = path;
        },
        onDownloadError: (String error) {},
      );
    }
    isDownloadingDB.value = false;
  }

  unzip() async {
    await requestStoragePermission();
    unzippingstatus.value = true;
    if (await File("/storage/emulated/0/Download/Books.db").exists()) {
      File("/storage/emulated/0/Download/Books.db").delete();
      Directory destinationDir = Directory("/storage/emulated/0/Download/");
      final zipFile = File("/storage/emulated/0/Download/Books.zip");
      try {
        await ZipFile.extractToDirectory(
            zipFile: zipFile, destinationDir: destinationDir);
        openDatabaseConnectionWithPath("/storage/emulated/0/Download/Books.db");
      } catch (e) {
        loadingprogress.value = e.toString();
        print(e);
      }
      isDownloadingDB.value = false;
    } else {
      Directory destinationDir = Directory("/storage/emulated/0/Download/");
      final zipFile = File("/storage/emulated/0/Download/Books.zip");
      try {
        await ZipFile.extractToDirectory(
            zipFile: zipFile, destinationDir: destinationDir);
        openDatabaseConnectionWithPath("/storage/emulated/0/Download/Books.db");
      } catch (e) {
        print(e);
      }
    }
    unzippingstatus.value = false;
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      return;
    }
    var result = await Permission.storage.request();
    if (result.isGranted) {
    } else {}
  }

  downloadandapplyDB() async {
    await downloadFile();
    await unzip();
  }

  clearTempFiles() async {
    await File("/storage/emulated/0/Download/Books.db").delete();
    await File(filePathZip).delete();
  }
}
