import 'dart:io';

import 'package:flutter/material.dart';

import '../images/images.dart';

class ImagePreviewScreen extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;

  const ImagePreviewScreen({super.key, this.imageFile, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Preview'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: imageFile != null
              ? Image.file(imageFile!, fit: BoxFit.contain)
              : imageUrl != null
                  ? ExtendedCachedImage(imageUrl: imageUrl)
                  : const Text('No image available'),
        ),
      ),
    );
  }
}
