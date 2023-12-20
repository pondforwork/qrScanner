import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/screen/addCategory.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 102,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text('Add Category'),
            onTap: () {
              Get.to(() => addCategory());
              // Add your navigation logic or other actions here
              // Navigator.pop(context); // Close the drawer
            },
          ),
          // ListTile(
          //   title: Text('Item 2'),
          //   onTap: () {
          //     // Add your navigation logic or other actions here
          //     Navigator.pop(context); // Close the drawer
          //   },
          // ),
          // Add more ListTiles for additional items
        ],
      ),
    );
  }
}
