import 'dart:ffi';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:qr_scan/controller/usercontroller.dart';
import 'package:qr_scan/models/chekedbook.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_archive/flutter_archive.dart' as flutter_archive;
// import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as diolib;

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
  RxBool continuousScan = false.obs;
  final dio = diolib.Dio();

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
        if (scandbhelper.checkDuplicateBook(barcode)) {
          //showDialogDuplicate
          showDuplicateSnackbar();
          //Need To add update Data
        }
        savefoundbook(firstValue, firstResult['TITLE'], firstResult);
      } else {
        resultSearch.value = "No result";
        showDialogNotFound(barcode);
      }
    } else {
      print("Select DB First");
    }
  }

  // testInsert() async {
  //   if (checkdbAvial() == true) {
  //     await _openLocalDatabase();
  //     List<Map<String, dynamic>> result = await _database!
  //         .rawQuery("SELECT * FROM books WHERE BARCODE LIMIT 500");
  //     print(result.length);
  //     for (Map<String, dynamic> item in result) {
  //       testsavefoundbook(item['TITLE'], item['BARCODE'], item);
  //       print(item);
  //     }
  //     print(result);
  //   }
  // }

  Future<void> testInsert(int limit) async {
    if (checkdbAvial()) {
      await _openLocalDatabase();
      List<Map<String, dynamic>> result =
          await _database!.rawQuery("SELECT * FROM books LIMIT $limit");
      print(result.length);
      for (Map<String, dynamic> item in result) {
        testsavefoundbook(item['TITLE'], item['BARCODE'], item);
        print(item);
      }
      print(result);
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

  void savefoundbook(
      String bookName, String barcode, Map<String, dynamic> firstResult) {
    DateTime checktime = DateTime.now();
    // First Save
    Checkedbook checkedbook = Checkedbook(
        firstResult['BARCODE'] ?? "",
        firstResult['CALLNO'] ?? "",
        firstResult['TITLE'] ?? "",
        firstResult['AUTHOR'] ?? "",
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
        checkedbook.author,
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
    // scandbhelper.fetchToDo();

    scandbhelper.latestcheckedbook.add(checkedbook);
    print("Add to temp length is ");
    print(scandbhelper.latestcheckedbook.length);
  }

  void testsavefoundbook(
      String bookName, String barcode, Map<String, dynamic> firstResult) {
    DateTime checktime = DateTime.now();
    // First Save
    Checkedbook checkedbook = Checkedbook(
        firstResult['BARCODE'] ?? "",
        firstResult['CALLNO'] ?? "",
        firstResult['TITLE'] ?? "",
        firstResult['AUTHOR'] ?? "",
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
    scandbhelper.testaddData(
        checkedbook.barcode,
        checkedbook.callNo,
        checkedbook.title,
        checkedbook.author,
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
    // scandbhelper.fetchToDo();
  }

  showDialogNotFound(String barcode) async {
    TextEditingController titleController = TextEditingController();
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
            const Text(
              "กรุณาใส่ข้อมูลหนังสือด้านล่าง",
              style: TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 20),
            Text(
              "BARCODE : $barcode",
              style: TextStyle(fontSize: 16),
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
                // if (scandbhelper.checkDuplicateBook(barcode)) {
                //   //ShowDialog
                //   scandbhelper.updateDuplicatebook(barcode);
                //   showDuplicateSnackbar();
                // }else{
                //   // showSavedBookSnackbar(title);
                // }
                DateTime checktime = DateTime.now();
                Checkedbook checkedbook = Checkedbook(
                    barcode,
                    callNocontroller.text,
                    titleController.text,
                    authorController.text,
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
                    checkedbook.author,
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

                // scandbhelper.fetchToDo();
              }
            }
          },
          child: const Text("ตกลง"),
        ),
      ],
    );
    continuousScan.value = false;
  }

  // Future<void> downloadfileIos() async {
  //   try {
  //     // Get the temporary directory
  //     final tempDir = await getTemporaryDirectory();
  //     final savePath = '${tempDir.path}/BooksZip.zip';

  //     // Download the file
  //     await diolib.Dio().download(
  //       'http://blackareauwu.xyz:5000/file/fa5bf957-d04a-4725-8b9a-efa5dab29c8a.zip',
  //       savePath,
  //     );

  //     print("File saved to $savePath");
  //   } catch (e) {
  //     print("Error downloading file: $e");
  //   }
  // }

  Future<void> downloadfileIos() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/BooksZip.zip';
      print("Start Download");
      await diolib.Dio().download(
        'http://blackareauwu.xyz:5000/file/fa5bf957-d04a-4725-8b9a-efa5dab29c8a.zip',
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            loadingprogress.value = (received / total).toString();
            print(loadingprogress);
          }
        },
      );
      print("File saved to $savePath");
      await unzipFileIos(savePath, tempDir.path);
    } catch (e) {
      print("Error downloading file: $e");
    }
  }

  Future<void> unzipFileIos(String zipFilePath, String destinationDir) async {
    try {
      final bytes = File(zipFilePath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (var file in archive) {
        final fileName = '$destinationDir/${file.name}';
        if (file.isFile) {
          final outFile = File(fileName);
          print('File:: ' + outFile.path);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
          if (fileName.endsWith('.db')) {
            await openDatabaseConnectionWithPath(fileName);
          }
        } else {
          await Directory(fileName).create(recursive: true);
        }
      }
      print("File unzipped to $destinationDir");
    } catch (e) {
      print("Error unzipping file: $e");
    }
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
    unzippingstatus.value = true;
    await requestStoragePermission();
    if (await File("/storage/emulated/0/Download/Books.db").exists()) {
      File("/storage/emulated/0/Download/Books.db").delete();
      Directory destinationDir = Directory("/storage/emulated/0/Download/");
      final zipFile = File("/storage/emulated/0/Download/Books.zip");
      try {
        await flutter_archive.ZipFile.extractToDirectory(
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
        await flutter_archive.ZipFile.extractToDirectory(
            zipFile: zipFile, destinationDir: destinationDir);
        openDatabaseConnectionWithPath("/storage/emulated/0/Download/Books.db");
      } catch (e) {
        print(e);
      }
    }
    unzippingstatus.value = false;
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      // Return the selected file path
      openDatabaseConnectionWithPath(result.files.single.path!);

      // return result.files.single.path;
    }
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
    // await File("/storage/emulated/0/Download/Books.db").delete();
    // await File("/storage/emulated/0/Download/Books.zip").delete();

    // await File(filePathZip).delete();
    try {
      // Delete Books.zip
      var zipFile = File("/storage/emulated/0/Download/Books.zip");
      if (zipFile.existsSync()) {
        await zipFile.delete();
        print("Deleted Zip");
      } else {
        print("Books.zip does not exist.");
      }

      // Delete Books.db
      var dbFile = File("/storage/emulated/0/Download/Books.db");
      if (dbFile.existsSync()) {
        await dbFile.delete();
        print("Deleted DB");
      } else {
        print("Books.db does not exist.");
      }
    } catch (e) {
      print("Error while deleting files: $e");
    }
  }

  showDuplicateSnackbar() {
    Get.snackbar(
      'คำเตือน', // Title
      'คุณเคยบันทึกหนังสือเล่มนี้แล้ว', // Message
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red, // Custom1ize the background color here
      colorText: Colors.white, // Customize the text color here
    );
  }

  showDialog() {
    Get.defaultDialog(
      title: "รีเซ็ตฐานข้อมูลหนังสือหรือไม่",
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text("จะไม่สามารถสแกนหนังสือได้จนกว่าจะดึงข้อมูลใหม่อีกครั้ง"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  resetBookDB();
                  Get.back();
                },
                child: const Text("ตกลง"),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text("ยกเลิก"),
              ),
            ],
          )
        ],
      ),
    );
  }

  resetBookDB() {
    isDownloadingDB.value = false;
    scandbhelper.currentdb.value = "No Database Selected";
    scandbhelper.resetDBName();
    scandbhelper.clearDBNameBox();
    try {
      deleteDBinDevice();
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteDBinDevice() async {
    try {
      // Delete Books.zip
      var zipFile = File("/storage/emulated/0/Download/Books.zip");
      if (zipFile.existsSync()) {
        await zipFile.delete();
      } else {
        print("Books.zip does not exist.");
      }

      // Delete Books.db
      var dbFile = File("/storage/emulated/0/Download/Books.db");
      if (dbFile.existsSync()) {
        await dbFile.delete();
      } else {
        print("Books.db does not exist.");
      }
    } catch (e) {
      print("Error while deleting files: $e");
    }
  }

  fetchBooksFromApi() {}

  void showMockDataDialog() {
    TextEditingController controller = TextEditingController();

    Get.defaultDialog(
      title: 'Enter Number of Mock Data',
      content: Padding(
        padding: EdgeInsets.all(8.0),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Number of Data'),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            // Close the dialog and return the input value

            testInsert(int.parse(controller.text));
            Get.back(result: int.tryParse(controller.text));
          },
          child: Text('OK'),
        ),
        ElevatedButton(
          onPressed: () {
            // Close the dialog without returning a value
            Get.back();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
