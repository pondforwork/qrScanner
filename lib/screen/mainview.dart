import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/categorycontroller.dart';
import 'package:qr_scan/screen/navbar.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.put(CategoryController());

    return Scaffold(
        appBar: AppBar(
          title: const Text("Qr Scan"),
        ),
        drawer: MyDrawer(), // Add the drawer here
        body: Center(
          child: Obx(() {
            if (categoryController.allCategory.isEmpty) {
              return const Center(
                child: Text("No Data"),
              );
            } else {
              // Using Obx to automatically rebuild the widget when the length changes
              return ListView.builder(
                itemCount: categoryController.allCategory.length,
                itemBuilder: (context, index) {
                  // Assuming your CategoryController has a list named 'categories'
                  final category = categoryController.allCategory[index];
                  return ListTile(
                    title: Text(category
                        .categoryName), // Adjust this according to your category model
                    // Add other widgets or customize the ListTile as needed
                  );
                },
              );
            }
          }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("Scan");
          },
          child: Icon(Icons.qr_code),
        ));
  }
}
