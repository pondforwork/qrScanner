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
  String selectedOption = 'Option 1';
  List<String> dropdownItems = ['One']; // Default values

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchData();
  }

  Future<void> fetchData() async {
    await categoryController.fetchCategoryNames().then((mockData) {
      setState(() {
        dropdownItems = mockData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String dropdownValue = dropdownItems[0];

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
              value: dropdownValue,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                         print(dropdownValue);
                });
              },
              items:
                  dropdownItems.map<DropdownMenuItem<String>>((String value) {
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


