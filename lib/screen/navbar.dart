import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                // ListTile(
                //   title: Text('Add Category'),
                //   onTap: () {
                //     Get.to(() => AddCategory());
                //   },
                // ),
                // ListTile(
                //   title: Text('All Product'),
                //   onTap: () {
                //     Get.to(() => ProductView());
                //   },
                // ),
                ListTile(
                  title: Text('Search DB'),
                  onTap: () {
                    Get.to(() => SearchBookView());
                  },
                ),
                ListTile(
                  title: Text('Select DB'),
                  onTap: () {
                    Get.to(() => SelectDBview());
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
