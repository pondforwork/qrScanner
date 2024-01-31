import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/categorycontroller.dart';
import 'package:qr_scan/controller/productcontroller.dart';

class SearchBookView extends StatelessWidget {
  const SearchBookView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(CategoryController());
    Get.put(ProductController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Book"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
              height: 300,
            ),
            Expanded(
              child: TextField(
                // controller: _controller,
                onSubmitted: (String value) async {
                  await showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Thanks!'),
                        content: Text(
                          'You typed "$value", which has length ${value.length}.',
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
