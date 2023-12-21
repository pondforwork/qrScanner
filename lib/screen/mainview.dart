import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/categorycontroller.dart';
import 'package:qr_scan/controller/dropdowncontroller.dart';
import 'package:qr_scan/screen/navbar.dart';
import 'package:qr_scan/screen/scanview.dart';

class MainView extends StatelessWidget {
  const MainView({Key? key});

  @override
  Widget build(BuildContext context) {
    // final categoryController = Get.put(CategoryController());
    DropdownController dropdownController = Get.put(DropdownController());

    // Now you can use dropdownController.dropdownItems in your UI to populate the dropdown.

    return Scaffold(
      appBar: AppBar(
        title: const Text("Qr Scan"),
      ),
      drawer: MyDrawer(), // Add the drawer here
      body: Column(
        children: [
          Expanded(
            child: GetX<CategoryController>(
              builder: (controller) {
                return ListView.builder(
                  itemCount:
                      controller.allCategory.length, // Use your item count here
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 80,
                      child: Card(
                          child: Center(
                        child: Text(
                          controller.allCategory[index].categoryName,
                          style: TextStyle(fontSize: 25),
                        ),
                      )),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          dropdownController.fetchDropdownItems();
          Get.to(() => DropdownPage());
          print("Scan");
        },
        child: Icon(Icons.qr_code),
      ),
    );
  }
}
