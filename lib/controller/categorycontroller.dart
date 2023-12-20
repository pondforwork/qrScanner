import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_scan/models/catgegory.dart';

class CartController extends GetxController {
  var allCategory = <ItemCategory>[].obs;
  Future<void> fetchCategory() async {
    try {
      final documentDirectory = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(documentDirectory.path);
      await Hive.openBox('category');
      var data = Hive.box('category');
      List<dynamic> values = data.values.toList();
      List<ItemCategory> allData = [];

      for (dynamic value in values) {
        if (value != null) {
          allData.add(ItemCategory(
            value['id'],
            value['category'],
            value['dateAdded'],
          ));
        }
      }

      // Sort the list by the "order" property
      // allData.sort((a, b) => a.order.compareTo(b.order));

      allCategory.assignAll(allData);
    } catch (error) {
      print("Error while accessing data: $error");
    }
  }
}
