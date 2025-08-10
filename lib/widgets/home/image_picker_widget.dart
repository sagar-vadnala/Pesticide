import 'package:flutter/material.dart';
import '../../model/picked_file_response.dart';
import '../../shared/ui/display_image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final PickedFileResponse? pickedFileResponse;
  final Function(PickedFileResponse?) onImagePicked;
  final VoidCallback onCreateForm;
  final bool showCancelButton;
  final VoidCallback onCancel;

  const ImagePickerWidget({
    super.key,
    required this.pickedFileResponse,
    required this.onImagePicked,
    required this.onCreateForm,
    required this.showCancelButton,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            height: 150,
            width: 250,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: DisplayImagePickerWidget(
                file: pickedFileResponse?.file,
                onFilePicked: onImagePicked,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: onCreateForm,
          child: const Text('Create Form'),
        ),
        if (showCancelButton)
          TextButton(
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
      ],
    );
  }
}
