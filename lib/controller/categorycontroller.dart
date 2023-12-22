import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_scan/models/catgegory.dart';
import 'package:uuid/uuid.dart';

class CategoryController extends GetxController {
  var allCategory = <ItemCategory>[].obs;
  RxList<String> globalList = <String>[].obs;
  
  @override
  void onInit() {
    fetchCategory();
    fetchCategoryNames().then((names) {
      globalList.assignAll(names);
    });

    super.onInit();
  }

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
            value['categoryName'],
            value['order'],
          ));
        }
      }

      // Sort the list by the "order" property
      // allData.sort((a, b) => a.order.compareTo(b.order));
      print("init");
      allCategory.assignAll(allData);
    } catch (error) {
      print("Error while accessing data: $error");
    }
  }

  Future<void> addCategory(String categoryName) async {
    try {
      final documentDirectory = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(documentDirectory.path);
      await Hive.openBox('category');
      var data = Hive.box('category');
      // Generate a unique ID for the new category
      String id = const Uuid().v4();
      DateTime order = DateTime.now();
      // Create a new ItemCategory instance
      var newCategory = ItemCategory(id, categoryName, order);
      print(id);
      // Save the new category to the Hive box
      await data.put(id, {
        'id': id,
        'categoryName': newCategory.categoryName,
        'order': newCategory.order
      });
      print("Insert Category");
      // Fetch the updated list of categories
      await fetchCategory();
      await fetchDropdown();
    } catch (error) {
      print("Error while adding category: $error");
    }
  }

  Future<List<String>> fetchCategoryNames() async {
    try {
      final documentDirectory = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(documentDirectory.path);
      await Hive.openBox('category');
      var data = Hive.box('category');
      List<dynamic> values = data.values.toList();
      List<String> categoryNames = [];

      for (dynamic value in values) {
        if (value != null) {
          categoryNames.add(value['categoryName']);
        }
      }

      return categoryNames;
    } catch (error) {
      print("Error while fetching category names: $error");
      return [];
    }
  }

  Future<void> fetchDropdown() async {
    fetchCategory();
    print("FetchFromController");
    fetchCategoryNames().then((names) {
      globalList.assignAll(names);
    });
  }

  
}
