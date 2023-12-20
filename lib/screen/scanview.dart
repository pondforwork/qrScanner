import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/dropdowncontroller.dart';

class DropdownPage extends StatelessWidget {
  final DropdownController dropdownController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dropdown Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Obx widget for reactive updates
              Obx(
                () => DropdownButton(
                  value: dropdownController.selectedItem.value.isNotEmpty
                      ? dropdownController.selectedItem.value
                      : dropdownController.dropdownItems.isNotEmpty
                          ? dropdownController.dropdownItems[0]
                          : null, // Set the default index (first item in the list)
                  items: dropdownController.dropdownItems
                      .map(
                        (String item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                  onChanged: (String? selectedItem) {
                    // Update the selected value in the controller
                    dropdownController.selectedItem.value = selectedItem!;

                    // Handle the selected item (you can remove this if you don't need it)
                    print("Selected Item: $selectedItem");
                  },
                ),
              ),
              SizedBox(height: 20),
              // Display the selected item
              // Obx(
              //   () => Text(
              //     'Selected Item: ${dropdownController.selectedItem}',
              //     style: TextStyle(fontSize: 18),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
