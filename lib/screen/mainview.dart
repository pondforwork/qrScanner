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
    final categoryController = Get.put(CategoryController());
    DropdownController dropdownController = Get.put(DropdownController());
// Now you can use dropdownController.dropdownItems in your UI to populate the dropdown.

    return Scaffold(
      appBar: AppBar(
        title: const Text("Qr Scan"),
      ),
      drawer: MyDrawer(), // Add the drawer here
      body: FutureBuilder(
        future: categoryController.fetchCategoryNames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (categoryController.globalList.isEmpty) {
            return const Center(
              child: Text("No Data"),
            );
          } else {
            // Now you can use categoryController.globalList as needed
            print(categoryController.globalList);

            return ListView.builder(
              itemCount: categoryController.globalList.length,
              itemBuilder: (context, index) {
                final categoryName = categoryController.globalList[index];
                return ListTile(
                  title: Text(categoryName),
                );
              },
            );
          }
        },
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
