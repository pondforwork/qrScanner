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
    //call category to load dropdown first
    // ignore: unused_local_variable
    final categoryController = Get.put(CategoryController());
    DropdownController dropdownController = Get.put(DropdownController());

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
            child: GetX<CategoryController>(
              builder: (controller) {
                return ListView.builder(
                  itemCount: controller.allCategory.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (controller.allCategory.length == 0) {
                      return const Center(
                        child: Text("No Data"),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () async {
                       
                        },
                        onLongPress: () {},
                        child: Container(
                          height: 80,
                          child: Card(
                              child: Center(
                            child: Text(
                              controller.allCategory[index].categoryName,
                              style: TextStyle(fontSize: 25),
                            ),
                          )),
                        ),
                      );
                    }
                  },
                );
              },
            ),
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
