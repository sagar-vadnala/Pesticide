import 'dart:io';
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
    // Validate input data to prevent NaN issues
    if (formDataList.isEmpty) {
      throw Exception('No data to generate PDF');
    }

    if (formFields.isEmpty) {
      throw Exception('No form fields configured');
    }

    await _loadCustomFont();

    final pdf = pw.Document();
    // Adjust rows per page based on dataset size
    final rowsPerPage = formDataList.length > 100 ? 8 : 5;
    final totalPages = (formDataList.length / rowsPerPage).ceil();

    // Validate totalPages to avoid division by zero
    if (totalPages <= 0) {
      throw Exception('Invalid page count');
    }

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final start = pageIndex * rowsPerPage;
      final end = (start + rowsPerPage) < formDataList.length
          ? start + rowsPerPage
          : formDataList.length;

      List<Map<String, dynamic>> pageItems = [];

      for (int i = start; i < end; i++) {
        final item = Map<String, dynamic>.from(formDataList[i]);
        print('DEBUG: Processing item $i: $item');

        if (item['image'] != null) {
          final pickedFile = item['image'] as PickedFileResponse;

          if (pickedFile.file.existsSync()) {
            try {
              final originalBytes = await pickedFile.file.readAsBytes();

              // Use original bytes without any processing to avoid NaN issues
              item['image'] = PickedFileResponse(
                file: pickedFile.file,
                bytes: originalBytes,
                mimeType: pickedFile.mimeType,
              );
            } catch (e) {
              print('Error loading image at index $i: $e');
              // Set placeholder for failed images
              item['image'] = null;
            }
          }
        }

        pageItems.add(item);

        // Safely update progress to avoid NaN
        final progress =
            formDataList.length > 0 ? (i + 1) / formDataList.length : 0.0;
        if (!progress.isNaN && progress.isFinite) {
          onProgressUpdate(progress.clamp(0.0, 1.0));
        }
      }

      // Create a copy of pageItems to avoid clearing before PDF is built
      final pageItemsCopy = List<Map<String, dynamic>>.from(pageItems);

      // Process this page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
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
                  border: pw.TableBorder.all(
                    width: 1.0,
                    color: PdfColors.black,
                  ),
                  columnWidths: _buildColumnWidths(formFields),
                  defaultVerticalAlignment:
                      pw.TableCellVerticalAlignment.middle,
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: _buildHeaderRow(formFields),
                    ),
                    for (int i = 0; i < pageItemsCopy.length; i++)
                      _buildTableRow(
                          pageItemsCopy[i], formFields, start + i + 1),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Clear page items from memory to free up space after building
      pageItems.clear();

      // Force garbage collection for large datasets
      if (formDataList.length > 100 && pageIndex % 5 == 0) {
        // Small delay to allow garbage collection
        await Future.delayed(const Duration(milliseconds: 10));
      }
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
    final columnWidths = <int, pw.TableColumnWidth>{};

    // Simple fixed widths to avoid any calculation issues
    columnWidths[0] = const pw.FixedColumnWidth(40); // Sr. No
    columnWidths[1] = const pw.FixedColumnWidth(120); // Image

    // All form field columns get equal flex width
    for (int i = 0; i < formFields.length; i++) {
      columnWidths[2 + i] = const pw.FlexColumnWidth(1.0);
    }

    return columnWidths;
  }

  static List<pw.Widget> _buildHeaderRow(List<FormFieldConfig> formFields) {
    final headers = <pw.Widget>[
      pw.Container(
        padding: const pw.EdgeInsets.all(4.0),
        child: pw.Text(
          'SR.NO',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            font: _customFont,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.Container(
        padding: const pw.EdgeInsets.all(4.0),
        child: pw.Text(
          'PICTURE',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            font: _customFont,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    ];

    // Add dynamic headers for form fields
    for (final field in formFields) {
      headers.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(4.0),
          child: pw.Text(
            field.label.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              font: _customFont,
            ),
            textAlign: pw.TextAlign.center,
          ),
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
      pw.Container(
        padding: const pw.EdgeInsets.all(8.0),
        child: pw.Text(
          '$index',
          style: pw.TextStyle(
            fontSize: 10,
            font: _customFont,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
      _buildImageCell(item['image']),
    ];

    // Add dynamic cells for form fields
    for (final field in formFields) {
      // Safely get text content and handle null/empty cases
      String cellContent = '';
      try {
        final formData = item['formData'];
        print('DEBUG: Processing field ${field.label}');
        print('DEBUG: FormData: $formData');

        if (formData != null && formData[field.label] != null) {
          cellContent = formData[field.label].toString();
          print('DEBUG: Cell content: $cellContent');
        } else {
          print('DEBUG: No data found for field ${field.label}');
        }
      } catch (e) {
        print('Error getting form data for field ${field.label}: $e');
        cellContent = '';
      }

      cells.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(
            cellContent,
            style: pw.TextStyle(
              fontSize: 10,
              font: _customFont,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      );
    }

    return pw.TableRow(children: cells);
  }

  static pw.Widget _buildImageCell(PickedFileResponse? image) {
    const double cellHeight = 80.0;

    if (image != null && image.bytes.isNotEmpty) {
      try {
        // Validate image bytes before creating image
        if (image.bytes.length < 10) {
          throw Exception('Image data too small');
        }

        // Use fixed minimal padding to avoid any calculation issues
        return pw.Container(
          height: cellHeight,
          padding: const pw.EdgeInsets.all(2.0),
          child: pw.Center(
            child: pw.Image(
              pw.MemoryImage(image.bytes),
              fit: pw.BoxFit.contain,
            ),
          ),
        );
      } catch (e) {
        print('Error creating PDF image: $e');
        return pw.Container(
          height: cellHeight,
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Center(
            child: pw.Text(
              'Image Error',
              style: pw.TextStyle(
                fontSize: 8,
                font: _customFont,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        );
      }
    } else {
      return pw.Container(
        height: cellHeight,
        padding: const pw.EdgeInsets.all(8.0),
        child: pw.Center(
          child: pw.Text(
            'No Image',
            style: pw.TextStyle(
              fontSize: 8,
              font: _customFont,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      );
    }
  }
}
