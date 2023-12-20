// ignore: file_names
// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class addCategory extends StatefulWidget {
  const addCategory({super.key});

  @override
  _addCategoryState createState() => _addCategoryState();
}

class _addCategoryState extends State<addCategory> {
  final TextEditingController _textField1Controller = TextEditingController();
  // final TextEditingController _textField2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: _textField1Controller,
                decoration: InputDecoration(
                  labelText: 'Text Field 1',
                ),
                validator: (value) {
                  if (value == null || value.length < 3) {
                    return 'Please enter at least 3 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
               
                decoration: InputDecoration(
                  labelText: 'Text Field 2',
                ),
                validator: (value) {
                  if (value == null || value.length < 3) {
                    return 'Please enter at least 3 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Validate the form and process the data
                  if (Form.of(context).validate()) {
                    // Your logic to handle the form data goes here
                    String textField1Value = _textField1Controller.text;
                    // String textField2Value = _textField2Controller.text;

                    print('Text Field 1: $textField1Value');
                   
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}