import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../model/picked_file_response.dart';
import '../model/form_field_config.dart';
import '../model/app_config.dart';

class PdfService {
  static pw.Font? _customFont;

  static Future<void> _loadCustomFont() async {
    if (_customFont == null) {
      try {
        final fontData =
            await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
        _customFont = pw.Font.ttf(fontData);
      } catch (e) {
        print('Error loading custom font: $e');
      }
    }
  }

  static Future<void> generateAndSharePdf({
    required List<Map<String, dynamic>> formDataList,
    required List<FormFieldConfig> formFields,
    required AppConfig appConfig,
    required Function(double) onProgressUpdate,
  }) async {
    await _loadCustomFont();

    final pdf = pw.Document();
    const rowsPerPage = 5;
    final totalPages = (formDataList.length / rowsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final start = pageIndex * rowsPerPage;
      final end = (start + rowsPerPage) < formDataList.length
          ? start + rowsPerPage
          : formDataList.length;

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
        onProgressUpdate((i + 1) / formDataList.length);
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text(
                  appConfig.title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    font: _customFont,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  appConfig.subtitle,
                  style: pw.TextStyle(
                    fontSize: 16,
                    font: _customFont,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: _buildColumnWidths(formFields),
                  children: [
                    pw.TableRow(children: _buildHeaderRow(formFields)),
                    for (int i = 0; i < pageItems.length; i++)
                      _buildTableRow(pageItems[i], formFields, start + i + 1),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    final directory = await getTemporaryDirectory();
    final file = File("${directory.path}/report.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: appConfig.title,
    );
  }

  static Map<int, pw.TableColumnWidth> _buildColumnWidths(
      List<FormFieldConfig> formFields) {
    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(35), // Sr. No
      1: const pw.FixedColumnWidth(100), // Image
    };

    // Add dynamic columns for form fields
    for (int i = 0; i < formFields.length; i++) {
      columnWidths[2 + i] = const pw.FlexColumnWidth();
    }

    return columnWidths;
  }

  static List<pw.Widget> _buildHeaderRow(List<FormFieldConfig> formFields) {
    final headers = <pw.Widget>[
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
        child: pw.Text('Sr. No'),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
        child: pw.Text('Display Image'),
      ),
    ];

    // Add dynamic headers for form fields
    for (final field in formFields) {
      headers.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
          child: pw.Text(field.label),
        ),
      );
    }

    return headers;
  }

  static pw.TableRow _buildTableRow(
    Map<String, dynamic> item,
    List<FormFieldConfig> formFields,
    int index,
  ) {
    final cells = <pw.Widget>[
      pw.Text('$index'),
      _buildImageCell(item['image']),
    ];

    // Add dynamic cells for form fields
    for (final field in formFields) {
      cells.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
          child: pw.Text(item['formData'][field.label] ?? ''),
        ),
      );
    }

    return pw.TableRow(children: cells);
  }

  static pw.Widget _buildImageCell(PickedFileResponse? image) {
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
        return pw.Text('Image Error');
      }
    } else {
      return pw.Text('No Image');
    }
  }
}
