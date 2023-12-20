import 'package:get/get.dart';
import 'package:qr_scan/controller/categorycontroller.dart';

class ScanScreenController extends GetxController {
  final categoryController = Get.find<CategoryController>();
  final dropdownValue = 'One'.obs; // Initial value
  final dropdownItems = <String>[].obs; // Empty list initially

  @override
  void onInit() {
    super.onInit();
    fetchCategoryNames();
  }

  void fetchCategoryNames() async {
    final mockData = await categoryController.fetchCategoryNames();
    dropdownItems.value = mockData;
  }

  void updateDropdownValue(String? newValue) {
    dropdownValue.value = newValue!;
  }
}
