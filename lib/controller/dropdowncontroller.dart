import 'package:get/get.dart';
import 'package:qr_scan/controller/categorycontroller.dart';

class DropdownController extends GetxController {
  RxList<String> dropdownItems = <String>[].obs;
  RxString selectedItem = ''.obs; // Observable variable for the selected item

  @override
  void onInit() {
    fetchDropdownItems();
    super.onInit();
  }

  Future<void> fetchDropdownItems() async {
    try {
      // Create an instance of the CategoryController
      CategoryController categoryController = Get.find();

      // Wait for the category names to be fetched
      await categoryController.fetchCategoryNames();
  
      // Get the category names from the CategoryController
      List<String> categoryNames = categoryController.globalList;

      // Assign the category names to the dropdownItems list
      dropdownItems.assignAll(categoryNames);
      print(categoryNames);
      print("FetchDropdown");

      print("Globallist");
      print(categoryController.globalList);
    } catch (error) {
      print("Error while fetching dropdown items: $error");
    }
  }
}
