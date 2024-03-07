import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/bookcontroller.dart';
import 'package:qr_scan/controller/checkedbookcontroller.dart';
import 'package:qr_scan/controller/scannercontroller.dart';

class ManageHistoryView extends StatelessWidget {
  ManageHistoryView({Key? key}) : super(key: key);
  final ScannerController scannercontroller = Get.put(ScannerController());
  final BookController bookController = Get.put(BookController());
  final scanDBhelper checkedbookcontroller = Get.put(scanDBhelper());
  final TextEditingController confirmTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Get.put(BookController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("จัดการประวัติการบันทึก"),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () {
                        return Text(
                          "คุณบันทึกหนังสือไปแล้ว " +
                              (checkedbookcontroller.foundqtyobs.value +
                                      checkedbookcontroller
                                          .notfoundqtyobs.value)
                                  .toString() +
                              " เล่ม",
                          style: TextStyle(fontSize: 20),
                        );
                      },
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () {
                        return Text(
                            "จำนวนหนังสือที่พบ " +
                                checkedbookcontroller.foundqtyobs.value
                                    .toString() +
                                " เล่ม",
                            style: TextStyle(fontSize: 20));
                      },
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () {
                        return Text(
                            "จำนวนหนังสือที่เกิน " +
                                checkedbookcontroller.notfoundqtyobs.value
                                    .toString() +
                                " เล่ม",
                            style: TextStyle(fontSize: 20));
                      },
                    )
                  ],
                )
              ]),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(200, 40),
                        textStyle: const TextStyle(
                            fontSize: 15, fontStyle: FontStyle.normal),
                        backgroundColor: Colors.green),
                    onPressed: () {
                      checkedbookcontroller.exportToCSV();
                    },
                    child: const Text(
                      'ส่งออกข้อมูล',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Obx(
                () => checkedbookcontroller.exportStatus.value == true
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(200, 40),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.normal,
                              ),
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              showConfirmationDialog();
                            },
                            child: const Text(
                              'ล้างข้อมูลการบันทึก',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    : Container(),
              )
            ],
          ),
        ),
      ]),
    );
  }

  void showConfirmationDialog() {
    Get.defaultDialog(
      title: 'ยืนยันการล้างข้อมูล',
      content: TextField(
        controller: confirmTextController,
        decoration: const InputDecoration(
          hintText: 'พิมพ์ "yes" และกดปุ่มยืนยัน เพื่อล้างข้อมูล',
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          if (confirmclear() == true) {
            await checkedbookcontroller.clearData();
            Get.back();
            Get.snackbar(
              'สำเร็จ',
              'ล้างข้อมูลเรียบร้อยแล้ว',
              snackPosition: SnackPosition.BOTTOM,
            );
            clearTextField();
          } else {
            Get.back();
            Get.snackbar(
              'ไม่อนุญาติการล้างข้อมูล',
              'กรุณาพิมพ์คำสั่งให้ถูกต้อง',
              snackPosition: SnackPosition.BOTTOM,
            );
            clearTextField();
          }
        },
        child: Text('ยืนยัน'),
      ),
      cancel: ElevatedButton(
        onPressed: () {
          Get.back();
          clearTextField();
        },
        child: Text('ยกเลิก'),
      ),
    );
  }

  bool confirmclear() {
    if (confirmTextController.text.toLowerCase() == "yes") {
      return true;
    } else {
      return false;
    }
  }

  void clearTextField() {
    confirmTextController.text = "";
  }
}
