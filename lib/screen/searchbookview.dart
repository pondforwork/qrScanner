import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/categorycontroller.dart';
import 'package:qr_scan/controller/productcontroller.dart';

class SearchBookView extends StatelessWidget {
  const SearchBookView({Key? key});
  @override
  Widget build(BuildContext context) {
    Get.put(CategoryController());
    Get.put(ProductController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Book"),
      ),
      body: GetX<ProductController>(
        builder: (controller) {
          if (controller.allProduct.isEmpty) {
            // Display a message when there are no products

            return const Center(
              child: Text("No Product",style: TextStyle(fontSize: 20),),
            );
          } else {
            // Display the list of products when there are items
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.allProduct.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 80,
                        child: Card(
                          child: Row(children: [Center(
                            child: Text(
                              controller.allProduct[index].name + " ID  ",
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                          Center(
                            child: Text(
                              controller.allProduct[index].resultscan,
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                          ],)
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
