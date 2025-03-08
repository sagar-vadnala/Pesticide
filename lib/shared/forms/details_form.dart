import 'dart:io';

import 'package:flutter/material.dart';

import '../../screens/image_preview/image_preview.dart';
import '../../screens/images/images.dart';

class FormScreen extends StatefulWidget {
  final File? imageFile;
  final String? imageUrl;
  final Map<String, String>? initialData;

  const FormScreen({
    super.key,
    this.imageFile,
    this.imageUrl,
    this.initialData,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final TextEditingController field1Controller = TextEditingController();
  final TextEditingController field2Controller = TextEditingController();
  final TextEditingController field3Controller = TextEditingController();
  final TextEditingController field4Controller = TextEditingController();
  final TextEditingController field5Controller = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      field1Controller.text = widget.initialData!['Field 1'] ?? '';
      field2Controller.text = widget.initialData!['Field 2'] ?? '';
      field3Controller.text = widget.initialData!['Field 3'] ?? '';
      field4Controller.text = widget.initialData!['Field 4'] ?? '';
      field5Controller.text = widget.initialData!['Field 5'] ?? '';
    }
  }

  @override
  void dispose() {
    field1Controller.dispose();
    field2Controller.dispose();
    field3Controller.dispose();
    field4Controller.dispose();
    field5Controller.dispose();
    super.dispose();
  }

  String? _validateMinLength(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    if (value.length < 2) {
      return 'At least 2 characters required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialData == null ? 'Create Form' : 'Edit Form'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePreviewScreen(
                        imageFile: widget.imageFile,
                        imageUrl: widget.imageUrl,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: widget.imageFile != null
                      ? Image.file(
                          widget.imageFile!,
                        )
                      : widget.imageUrl != null
                          ? ExtendedCachedImage(imageUrl: widget.imageUrl)
                          : const Center(child: Text('No image available')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: field1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Name of the area',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateMinLength,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: field2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Source Identified',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateMinLength,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: field3Controller,
                      decoration: const InputDecoration(
                        labelText: 'Type of infestation',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateMinLength,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: field4Controller,
                      decoration: const InputDecoration(
                        labelText: 'Actions plan by IPCS',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateMinLength,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: field5Controller,
                      decoration: const InputDecoration(
                        labelText: 'Action plan by Qentelli team',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateMinLength,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // If form is valid, proceed
                    final formData = {
                      'Name of the area': field1Controller.text,
                      'Source Identified': field2Controller.text,
                      'Type of infestation': field3Controller.text,
                      'Actions plan by IPCS': field4Controller.text,
                      'Action plan by Qentelli team': field5Controller.text,
                    };

                    Navigator.pop(context, formData); // Return form data to HomeScreen
                  }
                },
                child: Text(widget.initialData == null ? 'Submit Form' : 'Update Form'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
