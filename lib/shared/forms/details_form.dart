import 'dart:io';
import 'package:flutter/material.dart';
import '../../screens/image_preview/image_preview.dart';
import '../../screens/images/images.dart';
import '../../model/form_field_config.dart';

class FormScreen extends StatefulWidget {
  final File? imageFile;
  final String? imageUrl;
  final Map<String, String>? initialData;
  final List<FormFieldConfig>? formFields;

  const FormScreen({
    super.key,
    this.imageFile,
    this.imageUrl,
    this.initialData,
    this.formFields,
  });

  @override
  FormScreenState createState() => FormScreenState();
}

class FormScreenState extends State<FormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<TextEditingController> controllers = [];
  List<FormFieldConfig> formFields = [];

  @override
  void initState() {
    super.initState();
    _initializeFormFields();
  }

  void _initializeFormFields() {
    // Use provided form fields or default ones
    if (widget.formFields != null && widget.formFields!.isNotEmpty) {
      formFields = widget.formFields!;
    } else {
      // Default form fields if none provided
      formFields = [
        FormFieldConfig(id: 'field_1', label: 'Name of the area'),
        FormFieldConfig(id: 'field_2', label: 'Source Identified'),
        FormFieldConfig(id: 'field_3', label: 'Type of infestation'),
        FormFieldConfig(id: 'field_4', label: 'Actions plan by IPCS'),
        FormFieldConfig(id: 'field_5', label: 'Action plan by Qentelli team'),
      ];
    }

    // Initialize controllers
    controllers = List.generate(
      formFields.length,
      (index) => TextEditingController(),
    );

    // Load initial data if editing
    if (widget.initialData != null) {
      for (int i = 0; i < formFields.length && i < controllers.length; i++) {
        final field = formFields[i];
        controllers[i].text = widget.initialData![field.label] ?? '';
      }
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
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
                    ...formFields.asMap().entries.map((entry) {
                      final index = entry.key;
                      final field = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextFormField(
                          controller: controllers[index],
                          decoration: InputDecoration(
                            labelText: field.label,
                            border: const OutlineInputBorder(),
                          ),
                          validator:
                              field.isRequired ? _validateMinLength : null,
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // If form is valid, proceed
                    final formData = <String, String>{};
                    for (int i = 0;
                        i < formFields.length && i < controllers.length;
                        i++) {
                      formData[formFields[i].label] = controllers[i].text;
                    }

                    Navigator.pop(
                        context, formData); // Return form data to HomeScreen
                  }
                },
                child: Text(
                    widget.initialData == null ? 'Submit Form' : 'Update Form'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
