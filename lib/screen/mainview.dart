import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/categorycontroller.dart';
import 'package:qr_scan/screen/navbar.dart';
import 'package:qr_scan/screen/scanview.dart';

class MainView extends StatelessWidget {
  const MainView({Key? key});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.put(CategoryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Qr Scan"),
      ),
      drawer: MyDrawer(), // Add the drawer here
      body: FutureBuilder(
        future: categoryController.fetchCategory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (categoryController.allCategory.isEmpty) {
            return const Center(
              child: Text("No Data"),
            );
          } else {
            // Extract category names from allCategory and store them in a List<String>
            List<String> categoryNamesList = categoryController.allCategory
                .map((category) => category.categoryName)
                .toList();

            // Now you can use categoryNamesList as needed, for example, print it
            print(categoryNamesList);

            return ListView.builder(
              itemCount: categoryNamesList.length,
              itemBuilder: (context, index) {
                final categoryName = categoryNamesList[index];
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
          Get.to(() => ScanScreen());
          print("Scan");
        },
        child: Icon(Icons.qr_code),
      ),
    );
  }
}
