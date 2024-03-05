import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:qr_scan/controller/bookcontroller.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:qr_scan/controller/scannercontroller.dart';
import 'package:intl/intl.dart';

import '../models/chekedbook.dart';

class HistoryView extends StatelessWidget {
  HistoryView({Key? key}) : super(key: key);
  final ScannerController scannercontroller = Get.put(ScannerController());
  final BookController bookController = Get.put(BookController());
  final scanDBhelper checkedbookcontroller = Get.put(scanDBhelper());

  @override
  Widget build(BuildContext context) {
    Get.put(BookController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("ประวัติการบันทึก"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.archive_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              checkedbookcontroller.exportToCSV();
            },
          ),
        ],
      ),
      body: GroupedListView<dynamic, String>(
        elements: checkedbookcontroller.todo,
        groupBy: (element) =>
            '${element.checktime.day}-${element.checktime.month}-${element.checktime.year}',
        groupSeparatorBuilder: (String value) => buildGroupHeader(value),
        itemBuilder: (context, dynamic element) {
          final item = element as Checkedbook;
          return buildListItem(item);
        },
        order: GroupedListOrder.DESC,
        sort: false,
      ),
    );
  }

  Widget buildGroupHeader(String value) {
    final DateTime date = DateFormat('dd-MM-yyyy').parse(value);
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    return Container(
      height: 40,
      color: Colors.yellow,
      padding: const EdgeInsets.all(8),
      child: Text(
        formattedDate,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildListItem(Checkedbook item) {
    return GestureDetector(
      onLongPress: () {
        Get.defaultDialog(
          title: 'Delete Book',
          content: Text("Do you want to delete ${item.title}?"),
          confirm: ElevatedButton(
            onPressed: () async {
              await checkedbookcontroller.deleteData(item.barcode);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.normal,
              ),
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white),
            ),
          ),
          cancel: ElevatedButton(
            onPressed: () {
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.normal,
              ),
              backgroundColor: Colors.green,
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ExpansionTile(
              title: Text(
                item.title.length <= 50
                    ? item.title
                    : '${item.title.substring(0, 50)}...',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                item.barcode,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              trailing: FittedBox(
                child: Row(
                  children: [
                    item.found == "Y"
                        ? Image.asset(
                            'assets/images/correct.png',
                            width: 40,
                            height: 40,
                          )
                        : Image.asset(
                            'assets/images/incorrect.png',
                            width: 40,
                            height: 40,
                          ),
                    const SizedBox(
                      width: 10,
                    ),
                    item.exportstatus == false
                        ? Image.asset(
                            'assets/images/incorrect.png',
                            width: 40,
                            height: 40,
                          )
                        : Image.asset(
                            'assets/images/correct.png',
                            width: 40,
                            height: 40,
                          ),
                  ],
                ),
              ),
              children: [
                ListTile(
                  title: Text('Book Title: ${item.title}'),
                ),
                ListTile(
                  title: Text('Barcode: ${item.barcode}'),
                ),
                ListTile(
                  title: Text('Recorder: ${item.recorder}'),
                ),
                ListTile(
                  title: Text('Note: ${item.note}'),
                ),
                ListTile(
                  title: Text(
                    'Recorded Time: ${item.checktime.day.toString().padLeft(2, '0')}'
                    '/${item.checktime.month.toString().padLeft(2, '0')}'
                    '/${item.checktime.year} '
                    '${item.checktime.hour.toString().padLeft(2, '0')}'
                    ':${item.checktime.minute.toString().padLeft(2, '0')}'
                    ':${item.checktime.second.toString().padLeft(2, '0')}',
                  ),
                ),
                ListTile(
                  title: Text('ExportStatus: ${item.exportstatus}'),
                ),
              ],
            ),
          ),
          Icon(Icons.more_horiz_outlined)
        ],
      ),
    );
  }
}
