import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/usercontroller.dart';
import 'package:qr_scan/screen/historyview.dart';
import 'package:qr_scan/screen/loginview.dart';
import 'package:qr_scan/screen/scanview.dart';
import 'package:qr_scan/screen/selectdbview.dart';

class MyDrawer extends StatelessWidget {
  final UserController userController = Get.put(UserController());

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
                        Obx(() {
                          // Use Obx to listen to changes in userController.currentUser
                          if (userController.currentUser.value == "Guest") {
                            return Column(
                              children: [
                                const Text(
                                  'You Are Not Log In.',
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
                                    backgroundColor: Colors.white,
                                    minimumSize: Size(150, 50),
                                  ),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                const Text(
                                  'Welcome',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Display additional user information if needed
                                Text(
                                  'Logged in as: ${userController.currentUser.value}',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          }
                        }),
                      ],
                    ),
                  ),
                ),
                // Other list tile items
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
                Divider(),
                ListTile(
                  title: Text('Logout'),
                  onTap: () {
                    userController.signOut();
                    Get.offAll(Scanview());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
