import 'dart:io';
import 'dart:typed_data';
import 'package:hive/hive.dart';
import '../model/picked_file_response.dart';

class DataService {
  static const String _formDataKey = 'formDataList';
  static const String _formFieldsKey = 'formFields';
  static const String _appConfigKey = 'appConfig';

  static Future<Box> _getFormBox() async {
    return await Hive.openBox('formBox');
  }

  static Future<Box> _getConfigBox() async {
    return await Hive.openBox('configBox');
  }

  static Future<void> saveFormData(
      List<Map<String, dynamic>> formDataList) async {
    try {
      final formBox = await _getFormBox();
      final dataToStore = formDataList.map((item) {
        final image = item['image'] as PickedFileResponse?;
        return {
          'formData': item['formData'],
          'imagePath': image?.file.path,
          'imageMimeType': image?.mimeType,
        };
      }).toList();

      await formBox.put(_formDataKey, dataToStore);
    } catch (e) {
      print('Error saving form data: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> loadFormData() async {
    try {
      final formBox = await _getFormBox();
      final storedFormDataList = formBox.get(_formDataKey) as List?;

      if (storedFormDataList != null) {
        return storedFormDataList.map((item) {
          PickedFileResponse? pickedFile;
          if (item['imagePath'] != null && item['imageMimeType'] != null) {
            final file = File(item['imagePath']);
            if (file.existsSync()) {
              pickedFile = PickedFileResponse(
                file: file,
                bytes: Uint8List(0),
                mimeType: item['imageMimeType'],
              );
            }
          }
          return {
            'formData': Map<String, String>.from(item['formData']),
            'image': pickedFile,
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error loading form data: $e');
      return [];
    }
  }

  static Future<void> saveFormFields(
      List<Map<String, dynamic>> formFields) async {
    try {
      final configBox = await _getConfigBox();
      await configBox.put(_formFieldsKey, formFields);
    } catch (e) {
      print('Error saving form fields: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> loadFormFields() async {
    try {
      final configBox = await _getConfigBox();
      final savedFields = configBox.get(_formFieldsKey) as List?;
      return savedFields?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      print('Error loading form fields: $e');
      return [];
    }
  }

  static Future<void> saveAppConfig(Map<String, dynamic> appConfig) async {
    try {
      final configBox = await _getConfigBox();
      await configBox.put(_appConfigKey, appConfig);
    } catch (e) {
      print('Error saving app config: $e');
    }
  }

  static Future<Map<String, dynamic>?> loadAppConfig() async {
    try {
      final configBox = await _getConfigBox();
      final savedAppConfig =
          configBox.get(_appConfigKey) as Map<dynamic, dynamic>?;
      return savedAppConfig != null
          ? Map<String, dynamic>.from(savedAppConfig)
          : null;
    } catch (e) {
      print('Error loading app config: $e');
      return null;
    }
  }

  static Future<void> clearAllData() async {
    try {
      final formBox = await _getFormBox();
      final configBox = await _getConfigBox();

      await formBox.clear();
      await configBox.clear();
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}
