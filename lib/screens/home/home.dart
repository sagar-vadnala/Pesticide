import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';

import '../../model/picked_file_response.dart';
import '../../shared/forms/details_form.dart';
import '../../shared/ui/display_image_picker.dart';
import 'package:pdf/widgets.dart' as pw;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PickedFileResponse? pickedFileResponse;
  List<Map<String, dynamic>> formDataList = [];
  late Box formBox;
  late pw.Font customFont;
  bool showImagePicker = false;

  @override
  void initState() {
    super.initState();
    _openBox();
    _loadCustomFont();
  }

  Future<void> _openBox() async {
    formBox = await Hive.openBox('formBox');
    _loadFormData();
  }

  void _saveFormData() {
    formBox.put(
      'formDataList',
      formDataList.map((item) {
        return {
          'formData': item['formData'],
          'imagePath': item['image']?.file.path,
          'imageBytes': item['image']?.bytes,
          'imageMimeType': item['image']?.mimeType,
        };
      }).toList(),
    );
  }

  void _loadFormData() {
    final storedFormDataList = formBox.get('formDataList') as List?;
    if (storedFormDataList != null) {
      setState(() {
        formDataList = storedFormDataList.map((item) {
          PickedFileResponse? pickedFile;
          if (item['imagePath'] != null &&
              item['imageBytes'] != null &&
              item['imageMimeType'] != null) {
            pickedFile = PickedFileResponse(
              file: File(item['imagePath']),
              bytes: item['imageBytes'],
              mimeType: item['imageMimeType'],
            );
          }
          return {
            'formData': Map<String, String>.from(item['formData']),
            'image': pickedFile,
          };
        }).toList();
      });
    }
  }

  Future<void> _loadCustomFont() async {
    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    customFont = pw.Font.ttf(fontData);
  }

  Future<void> _generateAndDownloadPDF() async {
    final pdf = pw.Document();

    // Define the font style for centered text
    final centeredTextStyle = pw.TextStyle(
      fontSize: 14, // Increased font size
      font: customFont,
    );

    // Set rows per page to 5
    const rowsPerPage = 5;
    final totalPages = (formDataList.length / rowsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            final start = pageIndex * rowsPerPage;
            final end = (start + rowsPerPage) < formDataList.length
                ? start + rowsPerPage
                : formDataList.length;

            return pw.Column(
              children: [
                pw.Text(
                  'INDIAN PEST CARE SERVICES',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    font: customFont,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(35), // Sr. No column width
                    1: const pw.FixedColumnWidth(100), // Image column width
                    2: const pw.FlexColumnWidth(), // Flex width columns
                    3: const pw.FlexColumnWidth(),
                    4: const pw.FlexColumnWidth(),
                    5: const pw.FlexColumnWidth(),
                    6: const pw.FlexColumnWidth(),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                          child: pw.Text(
                            'Sr. No',
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                          child: pw.Text(
                            'Display Image',
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                          child: pw.Text(
                            'Name of the area',
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                          child: pw.Text(
                            'Source Identified',
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                          child: pw.Text(
                            'Infestation type',
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                          child: pw.Text(
                            'Actions plan by IPCS',
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                          child: pw.Text(
                            'Action plan by Qentelli team',
                          ),
                        ),
                      ],
                    ),
                    for (int i = start; i < end; i++)
                      pw.TableRow(
                        children: [
                          pw.Text('${i + 1}', style: centeredTextStyle),
                          formDataList[i]['image'] != null
                              ? pw.Image(
                                  pw.MemoryImage(formDataList[i]['image']!.bytes),
                                  height: 100, // Increased image height
                                  width: 100, // Increased image width
                                  fit: pw.BoxFit.cover, // Ensures image takes up full cell space
                                )
                              : pw.Text('No Image', style: centeredTextStyle),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                            child: pw.Text(formDataList[i]['formData']['Name of the area'] ?? '',
                                style: centeredTextStyle),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                            child: pw.Text(formDataList[i]['formData']['Source Identified'] ?? '',
                                style: centeredTextStyle),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                            child: pw.Text(formDataList[i]['formData']['Type of infestation'] ?? '',
                                style: centeredTextStyle),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                            child: pw.Text(
                                formDataList[i]['formData']['Actions plan by IPCS'] ?? '',
                                style: centeredTextStyle),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                            child: pw.Text(
                                formDataList[i]['formData']['Action plan by Qentelli team'] ?? '',
                                style: centeredTextStyle),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    // Save PDF to a temporary file and share
    final directory = await getTemporaryDirectory();
    final file = File("${directory.path}/indian_pest_services.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'INDIAN PEST CARE SERVICES',
    );
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
                  Navigator.of(context).pop(); // Close dialog without deleting
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
                    Navigator.of(context).pop(); // Close dialog after deleting
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INDIAN PEST CARE SERVICES'),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (formDataList.isEmpty || showImagePicker)
                _buildImagePickerWidget()
              else
                _buildDataTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerWidget() {
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
                onFilePicked: (file) {
                  setState(() {
                    pickedFileResponse = file;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => _navigateToFormScreen(null),
          child: const Text('Create Form'),
        ),
        if (formDataList.isNotEmpty)
          TextButton(
            onPressed: () {
              setState(() {
                showImagePicker = false;
              });
            },
            child: const Text('Cancel'),
          ),
      ],
    );
  }

  Widget _buildDataTable() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.amber),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton(
                onPressed: _showDeleteConfirmationDialog,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red), // Set background color here
                ),
                child: const Text(
                  "Delete All Data",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton(
                onPressed: () {
                  setState(() {
                    showImagePicker = true;
                    pickedFileResponse = null;
                  });
                },
                child: const Text('Add New Entry'),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Sr. no', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Display Image', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Name of the area', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label:
                        Text('Source Identified', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label:
                        Text('Type of infestation', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Actions plan by IPCS',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Action plan by Qentelli team',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: formDataList.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final formData = data['formData'] as Map<String, String>;
                final pickedFile = data['image'] as PickedFileResponse?;

                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(
                      pickedFile?.file != null
                          ? Image.file(pickedFile!.file, width: 50, height: 80)
                          : const Text('No image'),
                    ),
                    DataCell(Text(formData['Name of the area'] ?? '')),
                    DataCell(Text(formData['Source Identified'] ?? '')),
                    DataCell(Text(formData['Type of infestation'] ?? '')),
                    DataCell(Text(formData['Actions plan by IPCS'] ?? '')),
                    DataCell(Text(formData['Action plan by Qentelli team'] ?? '')),
                    DataCell(
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _navigateToFormScreen(index),
                            child: const Icon(Icons.edit, color: Colors.blue),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _deleteEntry(index),
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
              headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) => Colors.grey[300],
              ),
              dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) => Colors.white,
              ),
              dividerThickness: 1,
              border: TableBorder.all(
                color: Colors.grey[400]!,
                width: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _generateAndDownloadPDF,
            child: const Text('Generate and Download PDF'),
          ),
        ],
      ),
    );
  }

  void _navigateToFormScreen(int? index) async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => FormScreen(
          imageFile: index != null ? formDataList[index]['image']?.file : pickedFileResponse?.file,
          initialData: index != null ? formDataList[index]['formData'] : null,
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
}
