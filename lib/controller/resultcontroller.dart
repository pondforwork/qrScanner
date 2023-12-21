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

      // 'id': newProduct.id,
      //   'resultScan': newProduct.resultscan,
      //   'name': name,
      //   'categoryName': categoryName,
      //   'dateAdded': newProduct.dateAdded

      // Sort the list by the "order" property
      // allData.sort((a, b) => a.order.compareTo(b.order));
      print("initProduct");
      allProduct.assignAll(allData);
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
}
