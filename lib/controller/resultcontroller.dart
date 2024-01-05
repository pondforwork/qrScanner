import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_scan/models/catgegory.dart';
import 'package:qr_scan/models/result.dart';
import 'package:uuid/uuid.dart';

class ProductController extends GetxController {
  var allProduct = <Product>[].obs;
  RxList<String> globalList = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProduct();
    // fetchProductByCategory('Books');
  }

  Future<void> fetchProduct() async {
    try {
      final documentDirectory = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(documentDirectory.path);
      await Hive.openBox('product');
      var data = Hive.box('product');
      List<dynamic> values = data.values.toList();
      List<Product> allData = [];

      for (dynamic value in values) {
        if (value != null) {
          allData.add(Product(
            value['id'],
            value['resultScan'],
            value['name'],
            value['categoryName'],
            value['dateAdded'],
          ));
        }
      }
      print("initProduct");
      allProduct.assignAll(allData);
    } catch (error) {
      print("Error while accessing data: $error");
    }
  }

  Future<void> fetchProductByCategory(String categoryName) async {
    try {
      final documentDirectory = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(documentDirectory.path);
      await Hive.openBox('product');
      var data = Hive.box('product');
      List<dynamic> values = data.values.toList();
      List<Product> filteredData = [];

      for (dynamic value in values) {
        if (value != null && value['categoryName'] == categoryName) {
          filteredData.add(Product(
            value['id'],
            value['resultScan'],
            value['name'],
            value['categoryName'],
            value['dateAdded'],
          ));
        }
      }
      // Sort the list if needed
      // filteredData.sort((a, b) => a.order.compareTo(b.order));
      print("Filtered Products for category '$categoryName': $filteredData");

      // Assign the filtered data to your GetX observable
      allProduct.assignAll(filteredData);
    } catch (error) {
      print("Error while accessing data: $error");
    }
  }

  Future<void> addProduct(
      String resultScan, String name, String categoryName) async {
    try {
      final documentDirectory = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(documentDirectory.path);
      await Hive.openBox('product');
      var data = Hive.box('product');
      // Generate a unique ID for the new category
      String id = const Uuid().v4();
      DateTime order = DateTime.now();
      // Create a new ItemCategory instance
      var newProduct = Product(id, resultScan, name, categoryName, order);
      print(id);
      // Save the new category to the Hive box
      await data.put(id, {
        'id': newProduct.id,
        'resultScan': newProduct.resultscan,
        'name': name,
        'categoryName': categoryName,
        'dateAdded': newProduct.dateAdded
      });
      print("Insert Product");
      await fetchProduct();
      // await fetchCategory();
    } catch (error) {
      print("Error while adding category: $error");
    }
  }

  Future<void> showMyDialog(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('AlertDialog Title'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('This is a demo alert dialog.'),
              Text('Would you like to approve of this message?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Approve'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  
}

