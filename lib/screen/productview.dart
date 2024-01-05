import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/categorycontroller.dart';
import 'package:qr_scan/controller/dropdowncontroller.dart';
import 'package:qr_scan/controller/productcontroller.dart';
import 'package:qr_scan/screen/navbar.dart';
import 'package:qr_scan/screen/scanview.dart';

class ProductView extends StatelessWidget {
  const ProductView({Key? key});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.put(CategoryController());
    // DropdownController dropdownController = Get.put(DropdownController());
    final productcontroller = Get.put(ProductController());

    // Now you can use dropdownController.dropdownItems in your UI to populate the dropdown.

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Result"),
      ),
      body: Column(
        children: [
          Expanded(
            child: GetX<ProductController>(
              builder: (controller) {
                return ListView.builder(
                  itemCount:
                      controller.allProduct.length, // Use your item count here
                  itemBuilder: (BuildContext context, int index) {
                    if (controller.allProduct.length == 0) {
                      return Center(child: Text("No Data"),);
                    } else {
                      return Container(
                        height: 80,
                        child: Card(
                            child: Center(
                          child: Text(
                            controller.allProduct[index].name,
                            style: TextStyle(fontSize: 25),
                          ),
                        )),
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
          //resultscan name categoryname
          productcontroller.addProduct("233r1432893204032","Lays","Snacl");
          print("Scan");
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
