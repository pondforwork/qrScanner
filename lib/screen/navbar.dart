import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/screen/addCategory.dart';
import 'package:qr_scan/screen/mainview.dart';
import 'package:qr_scan/screen/productview.dart';

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
                const SizedBox(
                  height: 110,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Add Category'),
                  onTap: () {
                    Get.to(() => AddCategory());
                  },
                ),
                ListTile(
                  title: Text('All Product'),
                  onTap: () {
                    Get.to(() => ProductView());
                  },
                ),
              ],
            ),
          ),
          // Container with social media links at the bottom
          Container(
            child: const Column(
              children: [
                Divider(),
                ListTile(
                  title: Text('Dev : Pharadon Sirijhan'),
                ),
                SizedBox(height: 30,)
              ],
            ),
            
          ),
        ],
      ),
    );
  }
}
