import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_scan/controller/categorycontroller.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({Key? key}) : super(key: key);

  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textField1Controller = TextEditingController();
  final categoryController = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign the GlobalKey to the Form
          child: Column(
            children: [
              TextFormField(
                controller: _textField1Controller,
                decoration: const InputDecoration(
                  labelText: 'Insert Category',
                ),
                validator: (value) {
                  if (value == null || value.length < 3) {
                    return 'Please enter at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Validate the form and process the data
                  if (_formKey.currentState!.validate()) {
                    // Your logic to handle the form data goes here
                    String categoryNameFromField = _textField1Controller.text;

                    // print('Text Field 1: $categoryNameFromField');
                    // categoryController.addCategory(categoryNameFromField);
                    // Get.back();
                    // print(categoryController.getCategoryNames());
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
