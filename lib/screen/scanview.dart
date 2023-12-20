import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/categorycontroller.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final categoryController = Get.put(CategoryController());

  // Mock data for the dropdown
  List<String> mockData = ['Option 1', 'Option 2', 'Option 3'];
  String selectedOption = 'Option 1';

  @override
  Widget build(BuildContext context) {
    var list = categoryController.fetchCategoryNames();
    print(list);
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Scanner"),
            SizedBox(height: 20),
            // DropdownButton widget
            DropdownButton<String>(
              value: selectedOption,
              onChanged: (String? newValue) {
                setState(() {
                  selectedOption = newValue!;
                });
              },
              items: mockData.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
