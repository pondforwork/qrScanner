import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/screen/navbar.dart';
import 'package:qr_scan/screen/scanview.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key});
  @override
  Widget build(BuildContext context) {
    //call category to load dropdown first
    // ignore: unused_local_variable
    // Now you can use dropdownController.dropdownItems in your UI to populate the dropdown.
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              width: 350,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: ElevatedButton(
                  onPressed: () {
                    print("Test");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/Google_Icon.png', 
                        width: 50, 
                        height: 50, 
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Login With Google",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
