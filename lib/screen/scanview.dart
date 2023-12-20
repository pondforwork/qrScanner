import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:qr_scan/controller/categorycontroller.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final categoryController = CategoryController();

  @override
  void initState() {
    super.initState();
  }

  String barcodeResult = "No data yet";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Scan Result:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              barcodeResult,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                scanBarcode();
              },
              child: Text('Scan Barcode'),
            ),
            SizedBox(height: 20),
            FutureBuilder<List<String>>(
              future: categoryController.fetchCategoryNames(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No category names available.');
                } else {
                  List<String> categoryNames = snapshot.data!;
                  return Column(
                    children: [
                      Text('Category Names:'),
                      SizedBox(height: 10),
                      // Display category names as a comma-separated string
                      Text(categoryNames.join(', ')),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> scanBarcode() async {
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666", // Color for the scan button
      "Cancel", // Text for the cancel button
      true, // Show flash icon
      ScanMode.BARCODE, // Specify the type of scan
    );
    setState(() {
      barcodeResult = barcodeScanResult;
    });
  }
}
