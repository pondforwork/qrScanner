import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/screen/navbar.dart';
import 'package:qr_scan/screen/scanview.dart';

class MainView extends StatelessWidget {
  const MainView({Key? key});
  @override
  Widget build(BuildContext context) {
    //call category to load dropdown first
    // ignore: unused_local_variable
    // Now you can use dropdownController.dropdownItems in your UI to populate the dropdown.
    SnackBar snackBar = const SnackBar(
      content: Text('No Prodruct Category. Please Add One On left Menu'),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Qr Scan"),
      ),
      drawer: MyDrawer(), // Add the drawer here
      body: Column(
        children: [
          Expanded(
            child: Container(),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => DropdownPage());
        },
        child: Icon(Icons.qr_code),
      ),
    );
  }
}
