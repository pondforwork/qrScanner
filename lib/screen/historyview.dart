import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:qr_scan/controller/scannercontroller.dart';
import 'package:intl/intl.dart';
import '../models/chekedbook.dart';

class HistoryView extends StatefulWidget {
  @override
  _HistoryViewState createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final ScannerController scannercontroller = Get.put(ScannerController());
  final scanDBhelper checkedbookcontroller = Get.put(scanDBhelper());
  late Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  @override
  void initState() {
    super.initState();
    print("Hello");
    _fetchAllBooks();
  }

  Future<void> _fetchAllBooks() async {
    await checkedbookcontroller.fetchAllBooks();
  }

// 2024-03-05
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ประวัติการบันทึก"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today,
              color: Colors.white,
            ),
            onPressed: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                selectedDate.value = pickedDate;
              } else {
                selectedDate.value = null;
              }
            },
          ),
        ],
      ),
      body: Obx(
        () {
          final filteredList = selectedDate.value == null
              ? checkedbookcontroller.checkedbook
              : checkedbookcontroller.checkedbook
                  .where((element) =>
                      element.checktime.day == selectedDate.value!.day &&
                      element.checktime.month == selectedDate.value!.month &&
                      element.checktime.year == selectedDate.value!.year)
                  .toList();

          if (filteredList.isEmpty) {
            return const Center(
              child: Text(
                'ไม่มีรายการในวันที่ท่านเลือก',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          } else {
            return GroupedListView<dynamic, String>(
              elements: filteredList,
              groupBy: (element) =>
                  '${element.checktime.day}-${element.checktime.month}-${element.checktime.year}',
              groupSeparatorBuilder: (String value) => buildGroupHeader(value),
              itemBuilder: (context, dynamic element) {
                final item = element as Checkedbook;
                return buildListItem(item);
              },
              order: GroupedListOrder.DESC,
              sort: false,
            );
          }
        },
      ),
    );
  }

  Widget buildGroupHeader(String value) {
    final DateTime date = DateFormat('dd-MM-yyyy').parse(value);
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    return Container(
      height: 40,
      color: Colors.green[400],
      padding: const EdgeInsets.all(8),
      child: Text(
        formattedDate,
        style: const TextStyle(
          color: Colors.white,
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
          title: 'ลบหนังสือเล่มนี้',
          content: Text("ต้องการลบ ${item.title} หรือไม่ ?"),
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
            child: const SizedBox(
              width: 50,
              child: Center(
                child: Text(
                  'ลบ',
                  style: TextStyle(color: Colors.white),
                ),
              ),
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
            child: const SizedBox(
              width: 50,
              child: Center(
                child: Text(
                  'ยกเลิก',
                  style: TextStyle(color: Colors.white),
                ),
              ),
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
                            'assets/icon/foundbooks.png',
                            width: 40,
                            height: 40,
                          )
                        : Image.asset(
                            'assets/icon/additionbooks.png',
                            width: 40,
                            height: 40,
                          ),
                    const SizedBox(
                      width: 10,
                    ),
                    item.exportstatus == false
                        ? Image.asset(
                            'assets/icon/didntexported.png',
                            width: 40,
                            height: 40,
                          )
                        : Image.asset(
                            'assets/icon/exported.png',
                            width: 40,
                            height: 40,
                          ),
                  ],
                ),
              ),
              children: [
                ListTile(
                  title: Text('ชื่อหนังสือ: ${item.title}'),
                ),
                ListTile(
                  title: Text('บาร์โค้ด: ${item.barcode}'),
                ),
                ListTile(
                  title: Text('ผู้บันทึก: ${item.recorder}'),
                ),
                ListTile(
                  title: Text('โน๊ต: ${item.note}'),
                ),
                ListTile(
                  title: Text(
                    'เวลาที่บันทึก: ${item.checktime.day.toString().padLeft(2, '0')}'
                    '/${item.checktime.month.toString().padLeft(2, '0')}'
                    '/${item.checktime.year} '
                    '${item.checktime.hour.toString().padLeft(2, '0')}'
                    ':${item.checktime.minute.toString().padLeft(2, '0')}'
                    ':${item.checktime.second.toString().padLeft(2, '0')}',
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_horiz_outlined)
        ],
      ),
    );
  }
}
