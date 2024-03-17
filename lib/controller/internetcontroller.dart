import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class InternetContoller extends GetxController {
  Future<bool> checkInternetConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }
}
