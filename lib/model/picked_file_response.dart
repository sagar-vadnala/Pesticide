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

  // Convert the object to a Map for storing in Hive
  Map<String, dynamic> toMap() {
    return {
      'filePath': file.path,
      'bytes': bytes,
      'mimeType': mimeType,
    };
  }

  // Create an object from a Map (retrieved from Hive)
  factory PickedFileResponse.fromMap(Map<String, dynamic> map) {
    return PickedFileResponse(
      file: File(map['filePath']),
      bytes: Uint8List.fromList(map['bytes']),
      mimeType: map['mimeType'],
    );
  }
}
