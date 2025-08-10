import 'dart:io';
import 'dart:typed_data';

class PickedFileResponse {
  final File file;
  final Uint8List bytes;
  final String mimeType;

  const PickedFileResponse({
    required this.file,
    required this.bytes,
    required this.mimeType,
  });

  // Create a lightweight version without bytes for storage
  PickedFileResponse withoutBytes() {
    return PickedFileResponse(
      file: file,
      bytes: Uint8List(0), // Empty bytes to save memory
      mimeType: mimeType,
    );
  }

  // Load bytes on demand
  Future<PickedFileResponse> loadBytes() async {
    if (bytes.isNotEmpty) {
      return this;
    }

    try {
      final loadedBytes = await file.readAsBytes();
      return PickedFileResponse(
        file: file,
        bytes: loadedBytes,
        mimeType: mimeType,
      );
    } catch (e) {
      // Return original if error occurs
      print('Error loading bytes: $e');
      return this;
    }
  }

  // Convert the object to a Map for storing in Hive
  Map<String, dynamic> toMap() {
    return {
      'filePath': file.path,
      'mimeType': mimeType,
      // Don't store bytes in Hive to avoid memory issues
    };
  }

  // Create an object from a Map (retrieved from Hive)
  factory PickedFileResponse.fromMap(Map<String, dynamic> map) {
    return PickedFileResponse(
      file: File(map['filePath']),
      bytes: Uint8List(0), // Initialize with empty bytes
      mimeType: map['mimeType'],
    );
  }
}
