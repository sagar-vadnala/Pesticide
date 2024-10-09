import 'dart:io';

import 'package:flutter/material.dart';

import '../../images/image_preview.dart';
import '../../widgets/images/images.dart';

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
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final TextEditingController field1Controller = TextEditingController();
  final TextEditingController field2Controller = TextEditingController();
  final TextEditingController field3Controller = TextEditingController();
  final TextEditingController field4Controller = TextEditingController();
  final TextEditingController field5Controller = TextEditingController();
  final TextEditingController field6Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      field1Controller.text = widget.initialData!['Field 1'] ?? '';
      field2Controller.text = widget.initialData!['Field 2'] ?? '';
      field3Controller.text = widget.initialData!['Field 3'] ?? '';
      field4Controller.text = widget.initialData!['Field 4'] ?? '';
      field5Controller.text = widget.initialData!['Field 5'] ?? '';
      field6Controller.text = widget.initialData!['Field 6'] ?? '';
    }
  }

  @override
  void dispose() {
    field1Controller.dispose();
    field2Controller.dispose();
    field3Controller.dispose();
    field4Controller.dispose();
    field5Controller.dispose();
    field6Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialData == null ? 'Create Form' : 'Edit Form'),
      ),
      body: SingleChildScrollView(
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
                    ? Image.file(widget.imageFile!, fit: BoxFit.cover)
                    : widget.imageUrl != null
                        ? ExtendedCachedImage(imageUrl: widget.imageUrl)
                        : const Center(child: Text('No image available')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: field1Controller,
                    decoration: const InputDecoration(
                      labelText: 'Field 1',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: field2Controller,
                    decoration: const InputDecoration(
                      labelText: 'Field 2',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: field3Controller,
                    decoration: const InputDecoration(
                      labelText: 'Field 3',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: field4Controller,
                    decoration: const InputDecoration(
                      labelText: 'Field 4',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: field5Controller,
                    decoration: const InputDecoration(
                      labelText: 'Field 5',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: field6Controller,
                    decoration: const InputDecoration(
                      labelText: 'Field 6',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Submit form and return data
                final formData = {
                  'Field 1': field1Controller.text,
                  'Field 2': field2Controller.text,
                  'Field 3': field3Controller.text,
                  'Field 4': field4Controller.text,
                  'Field 5': field5Controller.text,
                  'Field 6': field6Controller.text,
                };

                Navigator.pop(context, formData); // Return form data to HomeScreen
              },
              child: Text(widget.initialData == null ? 'Submit Form' : 'Update Form'),
            ),
          ],
        ),
      ),
    );
  }
}
