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
  bool isGeneratingPdf = false;
  double pdfProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _openBox();
    _loadCustomFont();
  }

  @override
  void dispose() {
    pickedFileResponse = null;
    super.dispose();
  }

  Future<void> _openBox() async {
    formBox = await Hive.openBox('formBox');
    _loadFormData();
  }

  void _saveFormData() {
    try {
      final dataToStore = formDataList.map((item) {
        final image = item['image'] as PickedFileResponse?;
        return {
          'formData': item['formData'],
          'imagePath': image?.file.path,
          'imageMimeType': image?.mimeType,
        };
      }).toList();

      formBox.put('formDataList', dataToStore);
    } catch (e) {
      print('Error saving form data: $e');
    }
  }

  void _loadFormData() {
    try {
      final storedFormDataList = formBox.get('formDataList') as List?;
      if (storedFormDataList != null) {
        setState(() {
          formDataList = storedFormDataList.map((item) {
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
        });
      }
    } catch (e) {
      print('Error loading form data: $e');
    }
  }

  Future<void> _loadCustomFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      customFont = pw.Font.ttf(fontData);
    } catch (e) {
      print('Error loading custom font: $e');
    }
  }

  Future<void> _generateAndDownloadPDF() async {
    if (isGeneratingPdf) return;

    setState(() {
      isGeneratingPdf = true;
      pdfProgress = 0.0;
    });

    try {
      final pdf = pw.Document();

      final centeredTextStyle = pw.TextStyle(
        fontSize: 14,
        font: customFont,
      );

      const rowsPerPage = 5;
      final totalPages = (formDataList.length / rowsPerPage).ceil();

      for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
        final start = pageIndex * rowsPerPage;
        final end =
            (start + rowsPerPage) < formDataList.length ? start + rowsPerPage : formDataList.length;

        List<Map<String, dynamic>> pageItems = [];

        for (int i = start; i < end; i++) {
          final item = Map<String, dynamic>.from(formDataList[i]);

          if (item['image'] != null) {
            final pickedFile = item['image'] as PickedFileResponse;

            if (pickedFile.file.existsSync()) {
              try {
                final bytes = await pickedFile.file.readAsBytes();
                item['image'] = PickedFileResponse(
                  file: pickedFile.file,
                  bytes: bytes,
                  mimeType: pickedFile.mimeType,
                );
              } catch (e) {
                print('Error loading image at index $i: $e');
              }
            }
          }

          pageItems.add(item);

          setState(() {
            pdfProgress = (i + 1) / formDataList.length;
          });
        }

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
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
                      0: const pw.FixedColumnWidth(35),
                      1: const pw.FixedColumnWidth(100),
                      2: const pw.FlexColumnWidth(),
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
                            child: pw.Text('Sr. No'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                            child: pw.Text('Display Image'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                            child: pw.Text('Name of the area'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                            child: pw.Text('Source Identified'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                            child: pw.Text('Infestation type'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                            child: pw.Text('Actions plan by IPCS'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                            child: pw.Text('Action plan by Qentelli team'),
                          ),
                        ],
                      ),
                      for (int i = 0; i < pageItems.length; i++)
                        _buildPdfTableRow(pageItems[i], centeredTextStyle, start + i + 1),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      }

      final directory = await getTemporaryDirectory();
      final file = File("${directory.path}/indian_pest_services.pdf");
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'INDIAN PEST CARE SERVICES',
      );
    } catch (e) {
      print('Error generating PDF: $e');
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
    } finally {
      if (mounted) {
        setState(() {
          isGeneratingPdf = false;
        });
      }
    }
  }

  pw.TableRow _buildPdfTableRow(Map<String, dynamic> item, pw.TextStyle style, int index) {
    return pw.TableRow(
      children: [
        pw.Text('$index', style: style),
        _buildPdfImageCell(item['image'], style),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
          child: pw.Text(item['formData']['Name of the area'] ?? '', style: style),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
          child: pw.Text(item['formData']['Source Identified'] ?? '', style: style),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
          child: pw.Text(item['formData']['Type of infestation'] ?? '', style: style),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
          child: pw.Text(item['formData']['Actions plan by IPCS'] ?? '', style: style),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
          child: pw.Text(item['formData']['Action plan by Qentelli team'] ?? '', style: style),
        ),
      ],
    );
  }

  pw.Widget _buildPdfImageCell(PickedFileResponse? image, pw.TextStyle textStyle) {
    if (image != null && image.bytes.isNotEmpty) {
      try {
        return pw.Container(
          height: 100,
          width: 100,
          child: pw.Center(
            child: pw.Image(
              pw.MemoryImage(image.bytes),
              height: 100,
              width: 100,
              fit: pw.BoxFit.cover,
            ),
          ),
        );
      } catch (e) {
        print('Error creating PDF image: $e');
        return pw.Text('Image Error', style: textStyle);
      }
    } else {
      return pw.Text('No Image', style: textStyle);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INDIAN PEST CARE SERVICES'),
        centerTitle: true,
        elevation: 1,
      ),
      body: isGeneratingPdf
          ? PdfGenerationProgressWidget(progress: pdfProgress)
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
                        onDeleteAllData: _showDeleteConfirmationDialog,
                        onAddNewEntry: () {
                          setState(() {
                            showImagePicker = true;
                            pickedFileResponse = null;
                          });
                        },
                        onEditEntry: (index) => _navigateToFormScreen(index),
                        onDeleteEntry: _deleteEntry,
                        onGeneratePdf: isGeneratingPdf ? null : _generateAndDownloadPDF,
                        isGeneratingPdf: isGeneratingPdf,
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Component Widget 1: PDF Generation Progress Widget
class PdfGenerationProgressWidget extends StatelessWidget {
  final double progress;

  const PdfGenerationProgressWidget({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(value: progress),
          const SizedBox(height: 16),
          Text('Generating PDF: ${(progress * 100).toInt()}%'),
        ],
      ),
    );
  }
}

// Component Widget 2: Image Picker Widget
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

// Component Widget 3: Data Table Widget
class DataTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> formDataList;
  final VoidCallback onDeleteAllData;
  final VoidCallback onAddNewEntry;
  final void Function(int) onEditEntry;
  final void Function(int) onDeleteEntry;
  final VoidCallback? onGeneratePdf;
  final bool isGeneratingPdf;

  const DataTableWidget({
    super.key,
    required this.formDataList,
    required this.onDeleteAllData,
    required this.onAddNewEntry,
    required this.onEditEntry,
    required this.onDeleteEntry,
    required this.onGeneratePdf,
    required this.isGeneratingPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.amber),
      child: Column(
        children: [
          // Top action buttons
          ActionButtonsRow(
            onDeleteAllData: onDeleteAllData,
            onAddNewEntry: onAddNewEntry,
          ),

          // Data table
          FormDataTable(
            formDataList: formDataList,
            onEditEntry: onEditEntry,
            onDeleteEntry: onDeleteEntry,
          ),

          const SizedBox(height: 16),

          // Generate PDF button
          ElevatedButton(
            onPressed: onGeneratePdf,
            child: Text(isGeneratingPdf ? 'Generating...' : 'Generate and Download PDF'),
          ),
        ],
      ),
    );
  }
}

// Component Widget 4: Action Buttons Row
class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onDeleteAllData;
  final VoidCallback onAddNewEntry;

  const ActionButtonsRow({
    super.key,
    required this.onDeleteAllData,
    required this.onAddNewEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FilledButton(
          onPressed: onDeleteAllData,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.red),
          ),
          child: const Text(
            "Delete All Data",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        FilledButton(
          onPressed: onAddNewEntry,
          child: const Text('Add New Entry'),
        ),
      ],
    );
  }
}

// Component Widget 5: Form Data Table
class FormDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> formDataList;
  final void Function(int) onEditEntry;
  final void Function(int) onDeleteEntry;

  const FormDataTable({
    super.key,
    required this.formDataList,
    required this.onEditEntry,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Sr. no', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Display Image', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Name of the area', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Source Identified', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Type of infestation', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Actions plan by IPCS', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Action plan by Qentelli team',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: formDataList.asMap().entries.map((entry) {
          return FormDataRow(
            index: entry.key,
            data: entry.value,
            onEdit: () => onEditEntry(entry.key),
            onDelete: () => onDeleteEntry(entry.key),
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
    );
  }
}

// Component Widget 6: Form Data Row
class FormDataRow extends DataRow {
  FormDataRow({
    required int index,
    required Map<String, dynamic> data,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) : super(
          cells: _buildCells(index, data, onEdit, onDelete),
        );

  static List<DataCell> _buildCells(
    int index,
    Map<String, dynamic> data,
    VoidCallback onEdit,
    VoidCallback onDelete,
  ) {
    final formData = data['formData'] as Map<String, String>;
    final pickedFile = data['image'] as PickedFileResponse?;

    return [
      DataCell(Text('${index + 1}')),
      DataCell(
        pickedFile?.file != null && pickedFile!.file.existsSync()
            ? Image.file(pickedFile.file, width: 50, height: 80)
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
              onTap: onEdit,
              child: const Icon(Icons.edit, color: Colors.blue),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    ];
  }
}
