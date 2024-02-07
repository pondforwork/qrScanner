import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/screen/historyview.dart';
import 'package:qr_scan/screen/loginview.dart';
import 'package:qr_scan/screen/searchbookview.dart';
import 'package:qr_scan/screen/selectdbview.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 200,
                  child: DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'You Are Not Logged In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.to(() => LoginView());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .white, // Set the background color to white
                            minimumSize: Size(150, 50),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color:
                                  Colors.black, // Set the text color to black
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Select DB'),
                  onTap: () {
                    Get.to(() => SelectDBview());
                  },
                ),
                ListTile(
                  title: Text('History and Export'),
                  onTap: () {
                    Get.to(() => HistoryView());
                  },
                ),
              ],
            ),
          ),
          // Container with social media links at the bottom
          // Container(
          //   child: const Column(
          //     children: [
          //       Divider(),
          //       ListTile(
          //         title: Text(''),
          //       ),
          //       SizedBox(height: 30,)
          //     ],
          //   ),

          // ),
        ],
      ),
    );
  }
}
