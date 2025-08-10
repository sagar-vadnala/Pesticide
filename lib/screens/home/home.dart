import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../model/picked_file_response.dart';
import '../../model/form_field_config.dart';
import '../../model/app_config.dart';
import '../../shared/forms/details_form.dart';
import '../../services/pdf_service.dart';
import '../../services/data_service.dart';
import '../../widgets/home/pdf_progress_widget.dart';
import '../../widgets/home/image_picker_widget.dart';
import '../../widgets/home/data_table_widget.dart';

class HomeScreen extends StatefulWidget {
  final List<FormFieldConfig>? formFields;
  final AppConfig? appConfig;

  const HomeScreen({super.key, this.formFields, this.appConfig});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PickedFileResponse? pickedFileResponse;
  List<Map<String, dynamic>> formDataList = [];
  bool showImagePicker = false;
  bool isGeneratingPdf = false;
  double pdfProgress = 0.0;
  List<FormFieldConfig> formFields = [];
  AppConfig appConfig = AppConfig(
    title: 'INDIAN PEST CARE SERVICES',
    subtitle: 'Pest Control Report',
  );

  @override
  void initState() {
    super.initState();
    _loadData();

    // Set landscape orientation for this screen
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  void dispose() {
    pickedFileResponse = null;
    // Reset orientation when leaving this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _loadData() async {
    // Load form data
    final loadedFormData = await DataService.loadFormData();
    setState(() {
      formDataList = loadedFormData;
    });

    // Load form fields
    if (widget.formFields != null) {
      setState(() {
        formFields = widget.formFields!;
      });
    } else {
      final savedFields = await DataService.loadFormFields();
      if (savedFields.isNotEmpty) {
        setState(() {
          formFields = savedFields
              .map((field) => FormFieldConfig.fromJson(field))
              .toList();
        });
      }
    }

    // Load app config
    if (widget.appConfig != null) {
      setState(() {
        appConfig = widget.appConfig!;
      });
    } else {
      final savedAppConfig = await DataService.loadAppConfig();
      if (savedAppConfig != null) {
        setState(() {
          appConfig = AppConfig.fromJson(savedAppConfig);
        });
      }
    }
  }

  Future<void> _saveFormData() async {
    await DataService.saveFormData(formDataList);
  }

  Future<void> _generateAndDownloadPDF() async {
    if (isGeneratingPdf) return;

    setState(() {
      isGeneratingPdf = true;
      pdfProgress = 0.0;
    });

    try {
      await PdfService.generateAndSharePdf(
        formDataList: formDataList,
        formFields: formFields,
        appConfig: appConfig,
        onProgressUpdate: (progress) {
          if (mounted) {
            setState(() {
              pdfProgress = progress;
            });
          }
        },
      );
    } catch (e) {
      print('Error generating PDF: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to generate PDF: ${e.toString()}'),
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
      }
    } finally {
      if (mounted) {
        setState(() {
          isGeneratingPdf = false;
        });
      }
    }
  }

  void _deleteEntry(int index) {
    setState(() {
      formDataList.removeAt(index);
      _saveFormData();
      if (formDataList.isEmpty) {
        pickedFileResponse = null;
      }
    });
  }

  void _showDeleteConfirmationDialog() {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text('Delete All Data'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Code',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (textController.text == "DELETE") {
                    setState(() {
                      formDataList.clear();
                      pickedFileResponse = null;
                      _saveFormData();
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToFormScreen(int? index) async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => FormScreen(
          imageFile: index != null
              ? formDataList[index]['image']?.file
              : pickedFileResponse?.file,
          initialData: index != null ? formDataList[index]['formData'] : null,
          formFields: formFields,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (index != null) {
          formDataList[index]['formData'] = result;
        } else {
          formDataList.add({
            'formData': result,
            'image': pickedFileResponse,
          });
          pickedFileResponse = null;
        }
        showImagePicker = false;
        _saveFormData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              appConfig.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              appConfig.subtitle,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: isGeneratingPdf
          ? PdfProgressWidget(progress: pdfProgress)
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (formDataList.isEmpty || showImagePicker)
                      ImagePickerWidget(
                        pickedFileResponse: pickedFileResponse,
                        onImagePicked: (file) {
                          setState(() {
                            pickedFileResponse = file;
                          });
                        },
                        onCreateForm: () => _navigateToFormScreen(null),
                        showCancelButton: formDataList.isNotEmpty,
                        onCancel: () {
                          setState(() {
                            showImagePicker = false;
                          });
                        },
                      )
                    else
                      DataTableWidget(
                        formDataList: formDataList,
                        formFields: formFields,
                        onDeleteAllData: _showDeleteConfirmationDialog,
                        onAddNewEntry: () {
                          setState(() {
                            showImagePicker = true;
                            pickedFileResponse = null;
                          });
                        },
                        onEditEntry: (index) => _navigateToFormScreen(index),
                        onDeleteEntry: _deleteEntry,
                        onGeneratePdf:
                            isGeneratingPdf ? null : _generateAndDownloadPDF,
                        isGeneratingPdf: isGeneratingPdf,
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
