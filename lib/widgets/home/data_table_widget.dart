import 'package:flutter/material.dart';
import '../../model/form_field_config.dart';
import '../../model/picked_file_response.dart';

class DataTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> formDataList;
  final List<FormFieldConfig> formFields;
  final VoidCallback onDeleteAllData;
  final VoidCallback onAddNewEntry;
  final void Function(int) onEditEntry;
  final void Function(int) onDeleteEntry;
  final VoidCallback? onGeneratePdf;
  final bool isGeneratingPdf;

  const DataTableWidget({
    super.key,
    required this.formDataList,
    required this.formFields,
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
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: Colors.amber),
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
            formFields: formFields,
            onEditEntry: onEditEntry,
            onDeleteEntry: onDeleteEntry,
          ),

          const SizedBox(height: 16),

          // Generate PDF button
          ElevatedButton(
            onPressed: onGeneratePdf,
            child: Text(isGeneratingPdf
                ? 'Generating...'
                : 'Generate and Download PDF'),
          ),
        ],
      ),
    );
  }
}

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

class FormDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> formDataList;
  final List<FormFieldConfig> formFields;
  final void Function(int) onEditEntry;
  final void Function(int) onDeleteEntry;

  const FormDataTable({
    super.key,
    required this.formDataList,
    required this.formFields,
    required this.onEditEntry,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(
              label: Text('Sr. no',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          const DataColumn(
              label: Text('Display Image',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          ...formFields.map((field) => DataColumn(
                label: Text(field.label,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
          const DataColumn(
              label: Text('Actions',
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: formDataList.asMap().entries.map((entry) {
          return FormDataRow(
            index: entry.key,
            data: entry.value,
            formFields: formFields,
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

class FormDataRow extends DataRow {
  FormDataRow({
    required int index,
    required Map<String, dynamic> data,
    required List<FormFieldConfig> formFields,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) : super(
          cells: _buildCells(index, data, formFields, onEdit, onDelete),
        );

  static List<DataCell> _buildCells(
    int index,
    Map<String, dynamic> data,
    List<FormFieldConfig> formFields,
    VoidCallback onEdit,
    VoidCallback onDelete,
  ) {
    final formData = data['formData'] as Map<String, String>;
    final pickedFile = data['image'] as PickedFileResponse?;

    final cells = <DataCell>[
      DataCell(Text('${index + 1}')),
      DataCell(
        pickedFile?.file != null && pickedFile!.file.existsSync()
            ? Image.file(pickedFile.file, width: 50, height: 80)
            : const Text('No image'),
      ),
    ];

    // Add dynamic cells for form fields
    for (final field in formFields) {
      cells.add(DataCell(Text(formData[field.label] ?? '')));
    }

    // Add actions cell
    cells.add(
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
    );

    return cells;
  }
}
