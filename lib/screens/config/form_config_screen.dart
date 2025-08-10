import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../model/form_field_config.dart';
import '../../model/app_config.dart';
import '../home/home.dart';

class FormConfigScreen extends StatefulWidget {
  const FormConfigScreen({super.key});

  @override
  State<FormConfigScreen> createState() => _FormConfigScreenState();
}

class _FormConfigScreenState extends State<FormConfigScreen> {
  List<FormFieldConfig> formFields = [];
  late Box configBox;
  late TextEditingController titleController;
  late TextEditingController subtitleController;
  AppConfig appConfig = AppConfig(
    title: 'Report Title',
    subtitle: 'Report Subtitle',
  );

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    subtitleController = TextEditingController();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    configBox = await Hive.openBox('configBox');

    // Load form fields
    final savedFields = configBox.get('formFields') as List?;
    if (savedFields != null) {
      setState(() {
        formFields = savedFields
            .map((field) => FormFieldConfig.fromJson(field))
            .toList();
      });
    }

    // Load app config
    final savedAppConfig = configBox.get('appConfig') as Map<dynamic, dynamic>?;
    if (savedAppConfig != null) {
      setState(() {
        appConfig =
            AppConfig.fromJson(Map<String, dynamic>.from(savedAppConfig));
        titleController.text = appConfig.title;
        subtitleController.text = appConfig.subtitle;
      });
    } else {
      titleController.text = appConfig.title;
      subtitleController.text = appConfig.subtitle;
    }
  }

  void _saveConfig() {
    final fieldsJson = formFields.map((field) => field.toJson()).toList();
    configBox.put('formFields', fieldsJson);

    // Save app config
    appConfig = AppConfig(
      title: titleController.text,
      subtitle: subtitleController.text,
    );
    configBox.put('appConfig', appConfig.toJson());
  }

  void _addField() {
    setState(() {
      formFields.add(FormFieldConfig(
        id: 'field_${formFields.length + 1}',
        label: 'Field ${formFields.length + 1}',
      ));
    });
  }

  void _removeField(int index) {
    setState(() {
      formFields.removeAt(index);
      // Update IDs to maintain consistency
      for (int i = 0; i < formFields.length; i++) {
        formFields[i] = formFields[i].copyWith(id: 'field_${i + 1}');
      }
    });
  }

  void _updateField(int index, FormFieldConfig updatedField) {
    setState(() {
      formFields[index] = updatedField;
    });
  }

  void _startReporting() {
    if (formFields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one form field before starting.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _saveConfig();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          formFields: formFields,
          appConfig: appConfig,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Configuration'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1E2E),
              Color(0xFF2D2D44),
              Color(0xFF1E1E2E),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // App Configuration Section
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Add Report title and subtitle',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Report Title',
                        hintText: 'Enter your app title',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Report Subtitle',
                        hintText: 'Enter your app subtitle',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Form Fields List
              Expanded(
                child: formFields.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No form fields added yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the button below to add your first field',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: formFields.length,
                        itemBuilder: (context, index) {
                          return FormFieldCard(
                            field: formFields[index],
                            onUpdate: (updatedField) =>
                                _updateField(index, updatedField),
                            onDelete: () => _removeField(index),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addField,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Field'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startReporting,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Reporting'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FormFieldCard extends StatefulWidget {
  final FormFieldConfig field;
  final Function(FormFieldConfig) onUpdate;
  final VoidCallback onDelete;

  const FormFieldCard({
    super.key,
    required this.field,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<FormFieldCard> createState() => _FormFieldCardState();
}

class _FormFieldCardState extends State<FormFieldCard> {
  late TextEditingController labelController;
  late bool isRequired;

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController(text: widget.field.label);
    isRequired = widget.field.isRequired;
  }

  @override
  void dispose() {
    labelController.dispose();
    super.dispose();
  }

  void _updateField() {
    widget.onUpdate(FormFieldConfig(
      id: widget.field.id,
      label: labelController.text,
      isRequired: isRequired,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.text_fields,
                ),
                const SizedBox(width: 8),
                Text(
                  'Field ${widget.field.id.split('_').last}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isRequired,
                      onChanged: (value) {
                        setState(() {
                          isRequired = value ?? true;
                        });
                        _updateField();
                      },
                    ),
                    const Text('Required Field'),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            TextField(
              controller: labelController,
              onChanged: (_) => _updateField(),
              decoration: const InputDecoration(
                labelText: 'Column Label',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
