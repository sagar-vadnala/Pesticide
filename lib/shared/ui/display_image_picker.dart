import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../screens/image_preview/image_preview.dart';
import '../../model/picked_file_response.dart';
import '../../utils/dev.log.dart';
import '../../screens/images/images.dart';

class DisplayImagePickerWidget extends StatefulWidget {
  const DisplayImagePickerWidget({
    super.key,
    this.file,
    this.onFilePicked,
    this.url,
    this.shouldRemove,
  });

  final File? file;
  final void Function(PickedFileResponse?)? onFilePicked;
  final String? url;
  final void Function(bool)? shouldRemove;

  @override
  State<DisplayImagePickerWidget> createState() => DisplayImagePickerWidgetState();
}

class DisplayImagePickerWidgetState extends State<DisplayImagePickerWidget> {
  File? file;
  String? displayImageUrl;
  bool pickerLoading = false;

  @override
  void initState() {
    super.initState();
    file = widget.file;
    displayImageUrl = widget.url;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        final double maxWidth = isLandscape ? constraints.maxHeight * 16 / 9 : constraints.maxWidth;
        final double maxHeight =
            isLandscape ? constraints.maxHeight : constraints.maxWidth * 9 / 16;

        Widget image = Center(
          child: pickerLoading
              ? const SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined),
                      onPressed: () => pickFile(ImageSource.camera),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.photo_library),
                      onPressed: () => pickFile(ImageSource.gallery),
                    ),
                  ],
                ),
        );

        if (displayImageUrl != null && displayImageUrl!.isNotEmpty) {
          image = ExtendedCachedImage(imageUrl: displayImageUrl);
        }

        if (file != null && file?.path != null && file!.path.isNotEmpty) {
          image = Image.file(file!, fit: BoxFit.cover);
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: GestureDetector(
                    onTap: () {
                      if (file != null || displayImageUrl != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePreviewScreen(
                              imageFile: file,
                              imageUrl: displayImageUrl,
                            ),
                          ),
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            SizedBox(child: image),
                            if ((file != null && file?.path != null && file!.path.isNotEmpty) ||
                                (displayImageUrl != null && displayImageUrl!.isNotEmpty))
                              const SizedBox(height: 10),
                            if ((file != null && file?.path != null && file!.path.isNotEmpty) ||
                                (displayImageUrl != null &&
                                    displayImageUrl!.isNotEmpty &&
                                    widget.onFilePicked != null))
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (widget.shouldRemove != null) const Text(""),
                                    IconButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        backgroundColor: Colors.black,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          displayImageUrl = null;
                                          file = null;
                                        });
                                        widget.shouldRemove!(true);
                                        widget.onFilePicked!(null);
                                        Navigator.pop(context); // Pop back after deletion
                                      },
                                      icon: const Icon(Icons.delete, size: 25),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickFile(ImageSource source) async {
    try {
      if (widget.onFilePicked == null) {
        throw Exception('onFilePicker function must be provided');
      }
      final picker = ImagePicker();
      setState(() {
        pickerLoading = true;
      });
      final pickedFile = await picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (pickedFile != null) {
        setState(() {
          file = File(pickedFile.path);
        });
        widget.onFilePicked!(
          PickedFileResponse(
            file: File(pickedFile.path),
            bytes: await pickedFile.readAsBytes(),
            mimeType: pickedFile.mimeType ?? createMimeType(pickedFile.path),
          ),
        );
      }
    } catch (e, s) {
      Dev.error('Error selecting file', error: e, stackTrace: s);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        pickerLoading = false;
      });
    }
  }

  static String createMimeType(String path) {
    return 'image/${path.split(".").last}';
  }
}
