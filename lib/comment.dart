// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   PickedFileResponse? pickedFileResponse;
//   List<Map<String, dynamic>> formDataList = [];
//   bool isFormSubmitted = false;
//   bool isAddingNewEntry = false;
//   late Box formBox;
//   late pw.Font customFont; // To load custom font

//   @override
//   void initState() {
//     super.initState();
//     _openBox();
//     _loadCustomFont(); // Load the font in initState
//   }

//   Future<void> _openBox() async {
//     formBox = await Hive.openBox('formBox');
//     _loadFormData();
//   }

//   void _saveFormData() {
//     formBox.put(
//       'formDataList',
//       formDataList.map((item) {
//         return {
//           'formData': item['formData'],
//           'imagePath': item['image']?.file.path,
//           'imageBytes': item['image']?.bytes,
//           'imageMimeType': item['image']?.mimeType,
//         };
//       }).toList(),
//     );
//   }

//   void _loadFormData() {
//     final storedFormDataList = formBox.get('formDataList') as List?;
//     if (storedFormDataList != null) {
//       setState(() {
//         formDataList = storedFormDataList.map((item) {
//           PickedFileResponse? pickedFile;
//           if (item['imagePath'] != null &&
//               item['imageBytes'] != null &&
//               item['imageMimeType'] != null) {
//             pickedFile = PickedFileResponse(
//               file: File(item['imagePath']),
//               bytes: item['imageBytes'],
//               mimeType: item['imageMimeType'],
//             );
//           }
//           return {
//             'formData': Map<String, String>.from(item['formData']),
//             'image': pickedFile,
//           };
//         }).toList();
//         isFormSubmitted = formDataList.isNotEmpty;
//       });
//     }
//   }

//   Future<void> _loadCustomFont() async {
//     final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
//     customFont = pw.Font.ttf(fontData); // Load custom font
//   }

//   Future<void> _generateAndDownloadPDF() async {
//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) {
//           return pw.Column(
//             children: [
//               pw.Text(
//                 'Form Data Report',
//                 style: pw.TextStyle(
//                   fontSize: 24,
//                   fontWeight: pw.FontWeight.bold,
//                   font: customFont, // Apply the custom font here
//                 ),
//               ),
//               pw.SizedBox(height: 20),
//               pw.Table.fromTextArray(
//                 headers: [
//                   'Image',
//                   'Field 1',
//                   'Field 2',
//                   'Field 3',
//                   'Field 4',
//                   'Field 5',
//                   'Field 6'
//                 ],
//                 data: formDataList.map((formData) {
//                   final image = formData['image'] != null ? 'Image Selected' : 'No Image';
//                   final data = formData['formData'] as Map<String, String>;
//                   return [
//                     image,
//                     data['Field 1'] ?? '',
//                     data['Field 2'] ?? '',
//                     data['Field 3'] ?? '',
//                     data['Field 4'] ?? '',
//                     data['Field 5'] ?? '',
//                     data['Field 6'] ?? '',
//                   ];
//                 }).toList(),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     final directory = await getTemporaryDirectory();
//     final file = File("${directory.path}/form_data_report.pdf");
//     await file.writeAsBytes(await pdf.save());

//     // Share or download the PDF file
//     await Share.shareXFiles([XFile(file.path)], text: 'Form Data Report');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pesticides'),
//         centerTitle: true,
//         elevation: 1,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             if (isFormSubmitted)
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           isAddingNewEntry = true;
//                           pickedFileResponse = null;
//                         });
//                       },
//                       child: const Text('Add New Entry'),
//                     ),
//                     const SizedBox(height: 16),
//                     if (isAddingNewEntry)
//                       Column(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(top: 8.0),
//                             child: Center(
//                               child: SizedBox(
//                                 height: 250,
//                                 width: 250,
//                                 child: AspectRatio(
//                                   aspectRatio: 16 / 9,
//                                   child: DisplayImagePickerWidget(
//                                     file: pickedFileResponse?.file,
//                                     onFilePicked: (file) {
//                                       setState(() {
//                                         pickedFileResponse = file;
//                                       });
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(bottom: 8),
//                             child: FilledButton(
//                               onPressed: () async {
//                                 final result = await Navigator.push<Map<String, String>>(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => FormScreen(
//                                       imageFile: pickedFileResponse?.file,
//                                     ),
//                                   ),
//                                 );

//                                 if (result != null && pickedFileResponse != null) {
//                                   setState(() {
//                                     formDataList.add({
//                                       'formData': result,
//                                       'image': pickedFileResponse,
//                                     });
//                                     isFormSubmitted = true;
//                                     isAddingNewEntry = false;
//                                     _saveFormData();
//                                   });
//                                 }
//                               },
//                               child: const Text('Create Form'),
//                             ),
//                           ),
//                         ],
//                       ),
//                     if (formDataList.isNotEmpty)
//                       Column(
//                         children: [
//                           DataTable(
//                             columns: const [
//                               DataColumn(label: Text('Sr No')),
//                               DataColumn(label: Text('Image')),
//                               DataColumn(label: Text('Field 1')),
//                               DataColumn(label: Text('Field 2')),
//                               DataColumn(label: Text('Field 3')),
//                               DataColumn(label: Text('Field 4')),
//                               DataColumn(label: Text('Field 5')),
//                               DataColumn(label: Text('Field 6')),
//                               DataColumn(label: Text('Actions')),
//                             ],
//                             rows: formDataList.asMap().entries.map((entry) {
//                               final index = entry.key;
//                               final data = entry.value;
//                               final formData = data['formData'] as Map<String, String>;
//                               final pickedFile = data['image'] as PickedFileResponse?;

//                               return DataRow(cells: [
//                                 DataCell(Text('${index + 1}')),
//                                 DataCell(
//                                   pickedFile?.file != null
//                                       ? Image.file(pickedFile!.file, width: 50, height: 50)
//                                       : const Text('No image'),
//                                 ),
//                                 DataCell(Text(formData['Field 1'] ?? '')),
//                                 DataCell(Text(formData['Field 2'] ?? '')),
//                                 DataCell(Text(formData['Field 3'] ?? '')),
//                                 DataCell(Text(formData['Field 4'] ?? '')),
//                                 DataCell(Text(formData['Field 5'] ?? '')),
//                                 DataCell(Text(formData['Field 6'] ?? '')),
//                                 DataCell(
//                                   Row(
//                                     children: [
//                                       GestureDetector(
//                                         onTap: () async {
//                                           final result = await Navigator.push<Map<String, String>>(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) => FormScreen(
//                                                 imageFile: pickedFile?.file,
//                                                 initialData: formData,
//                                               ),
//                                             ),
//                                           );

//                                           if (result != null) {
//                                             setState(() {
//                                               formDataList[index]['formData'] = result;
//                                               _saveFormData();
//                                             });
//                                           }
//                                         },
//                                         child: const Icon(Icons.edit),
//                                       ),
//                                       GestureDetector(
//                                         onTap: () {
//                                           setState(() {
//                                             formDataList.removeAt(index);
//                                             _saveFormData();
//                                             isFormSubmitted = formDataList.isNotEmpty;
//                                           });
//                                         },
//                                         child: const Icon(Icons.delete, color: Colors.red),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ]);
//                             }).toList(),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//               )
//             else
//               Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Center(
//                       child: SizedBox(
//                         height: 250,
//                         width: 250,
//                         child: AspectRatio(
//                           aspectRatio: 16 / 9,
//                           child: DisplayImagePickerWidget(
//                             file: pickedFileResponse?.file,
//                             onFilePicked: (file) {
//                               setState(() {
//                                 pickedFileResponse = file;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: FilledButton(
//                       onPressed: () async {
//                         final result = await Navigator.push<Map<String, String>>(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => FormScreen(
//                               imageFile: pickedFileResponse?.file,
//                             ),
//                           ),
//                         );
//                         if (result != null && pickedFileResponse != null) {
//                           setState(() {
//                             formDataList.add({
//                               'formData': result,
//                               'image': pickedFileResponse,
//                             });
//                             isFormSubmitted = true;
//                             _saveFormData();
//                           });
//                         }
//                       },
//                       child: const Text('Create Form'),
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _generateAndDownloadPDF,
//         child: const Icon(Icons.picture_as_pdf),
//       ),
//     );
//   }
// }