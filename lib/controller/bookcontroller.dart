import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:qr_scan/controller/internetcontroller.dart';
import 'package:qr_scan/controller/usercontroller.dart';
import 'package:qr_scan/models/chekedbook.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_archive/flutter_archive.dart' as flutter_archive;
import 'package:dio/dio.dart' as diolib;
import 'package:http/http.dart' as http;

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
  final TextEditingController passwordTextController = TextEditingController();
  final InternetContoller internetContoller = InternetContoller();

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
          showDuplicateSnackbar();
        }
        // บันทึกปกติ
        savefoundbook(firstValue, firstResult['TITLE'], firstResult);
        scandbhelper.fetchToDo();
      } else {
        resultSearch.value = "No result";
        showDialogNotFound(barcode);
      }
    } else {
      print("Select DB First");
    }
  }

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

  Future<void> downloadfileIos() async {
    isDownloadingDB.value = true;

    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/BooksZip.zip';
      print("Start Download");
      await diolib.Dio().download(
        'https://platform.buu.in.th/downloads/Books.zip',
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            loadingprogress.value = (received / total).toStringAsFixed(2);
            print("Progress");
            print(loadingprogress);
          }
        },
      );
      print("File saved to $savePath");
      isDownloadingDB.value = false;

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
    try {
      var request = http.Request(
          'GET', Uri.parse('https://platform.buu.in.th/downloads/Books.zip'));
      var response = await request.send();

      // ตรวจสอบสถานะการตอบกลับ
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;

        // สร้างไฟล์ใหม่ใน directory ที่ได้
        final file = File('$path/Book.zip');

        // หา size ของไฟล์ทั้งหมด
        final totalBytes = response.contentLength ?? 0;
        int receivedBytes = 0;

        // อ่านข้อมูลจาก response และเขียนลงในไฟล์
        var byteStream =
            response.stream.transform<Uint8List>(StreamTransformer.fromHandlers(
          handleData: (List<int> data, sink) {
            sink.add(Uint8List.fromList(data));
            receivedBytes += data.length;

            // คำนวณความคืบหน้าแล้วส่งไปยัง UI
            if (totalBytes > 0) {
              double progress = receivedBytes / totalBytes;
              loadingprogress.value = (progress * 100).toStringAsFixed(2);
              // onProgress(progress);
              // downloadBloc.add(Downloading(progress));
              print(progress);
              // ถ้า Download เสร็จ
              // if (progress == 1.0) {
              //   updateDatabaseStatus();
              // }
            }
          },
        ));

        // เขียนข้อมูลที่ได้รับจาก byteStream ลงในไฟล์
        await file.writeAsBytes(
            await byteStream.expand((byte) => byte).toList(),
            flush: true);
        // print('File saved at: ${file.path}');

        await unzipFile(file.path, path);
      } else {
        // print('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error during file download: $e');
    }

    isDownloadingDB.value = false;
  }

  Future<void> unzipFile(String zipFilePath, String destinationPath) async {
    try {
      // Read the zip file
      final bytes = File(zipFilePath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      String? databaseFilePath;

      // Extract the contents to the destination folder
      for (final file in archive) {
        final filePath = '$destinationPath/${file.name}';
        if (file.isFile) {
          // Write the file
          final outputFile = File(filePath);
          await outputFile.create(recursive: true);
          await outputFile.writeAsBytes(file.content as List<int>);

          // Check if this is the database file
          if (filePath.endsWith('.db')) {
            databaseFilePath = filePath;
          }
        } else {
          // Create the directory
          await Directory(filePath).create(recursive: true);
        }
      }

      // Open the database connection if a database file was found
      if (databaseFilePath != null) {
        await openDatabaseConnectionWithPath(databaseFilePath);
        // print('Database connection opened for: $databaseFilePath');
      } else {
        // print('No database file found in the archive.');
      }

      // print('Unzipped successfully to $destinationPath');
    } catch (e) {
      // print('Error unzipping file: $e');
    }
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

  showPasswordDialog() {
    Get.defaultDialog(
      title: "รหัสผ่าน",
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextField(
            controller: passwordTextController,
            decoration: const InputDecoration(labelText: 'ใส่รหัสผ่านที่นี่'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  checkPasswordAndDownload(passwordTextController.text);
                  print(passwordTextController.text);
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

  Future<void> checkPasswordAndDownload(String password) async {
    if (password == 'inventory2024buu') {
      if (await internetContoller.checkInternetConnection()) {
        if (Platform.isAndroid) {
          Get.back();
          await downloadandapplyDB();
        } else if (Platform.isIOS) {
          await downloadfileIos();
        }
      } else {
        Get.back();
        internetContoller.shownoInternetDialog();
      }
    }
  }

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
