import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

void main() => runApp(const OCRApp());

class OCRApp extends StatelessWidget {
  const OCRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart OCR Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Roboto',
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const TextRecognitionScreen(),
    const ExportedFilesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Exports',
          ),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class TextRecognitionScreen extends StatefulWidget {
  const TextRecognitionScreen({super.key});

  @override
  _TextRecognitionScreenState createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();
  String _recognizedText = '';
  File? _selectedImage;
  bool _isProcessing = false;
Future<void> _checkPermissions(ImageSource source) async {
  if (source == ImageSource.camera) {
    var status = await Permission.camera.request();
    if (!status.isGranted) throw Exception('Camera permission denied');
  } else if (source == ImageSource.gallery) {
    var status = await Permission.photos.request();
    if (!status.isGranted) throw Exception('Gallery permission denied');
  }
}


  Future<File> _preprocessImage(File originalImage) async {
    try {
      final imageBytes = await originalImage.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) throw Exception('Failed to decode image');

      // Image processing pipeline
      final processedImage = _enhanceImage(decodedImage);

      // Save processed image to temporary file
      final tempDir = await getTemporaryDirectory();
      final processedFile = File(
          '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await processedFile.writeAsBytes(img.encodeJpg(processedImage));

      return processedFile;
    } catch (e) {
      throw Exception('Image processing failed: $e');
    }
  }
 img.Image _enhanceImage(img.Image image) {
  // Convert to grayscale
  img.Image processed = img.grayscale(image);
  
  // Increase contrast (adjust the 1.5 value as needed)
  processed = img.adjustColor(processed, contrast: 1.5);
  
  // Reduce noise with Gaussian blur
   processed = img.gaussianBlur(processed, radius: 1);  
  // Sharpen edges
   processed = img.convolution(
    processed,
    filter: [0, -1, 0, -1, 5, -1, 0, -1, 0], // Correct parameter name
    div: 1,
    offset: 0,
  );
  
  
  return processed;
}

  Future<void> _processImage(ImageSource source) async {
    try {
      await _checkPermissions(source);
      setState(() => _isProcessing = true);

      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile == null) return;

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final visionText = await _textRecognizer.processImage(inputImage);

      String result = '';
      for (TextBlock block in visionText.blocks) {
        for (TextLine line in block.lines) {
          result += '${line.text}\n';
        }
        result += '\n';
      }

      setState(() {
        _recognizedText = result;
        _selectedImage = File(pickedFile.path);
      });
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _exportFile(String format) async {
    if (_recognizedText.isEmpty) {
      _showError('No text to export');
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'OCR_Export_${DateTime.now().millisecondsSinceEpoch}';
      String path = '';

      switch (format) {
        case 'PDF':
          final pdf = pw.Document();
          pdf.addPage(pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) => pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Text(_recognizedText),
            ),
          ));
          path = '${dir.path}/$fileName.pdf';
          await File(path).writeAsBytes(await pdf.save());
          break;

        case 'TXT':
          path = '${dir.path}/$fileName.txt';
          await File(path).writeAsString(_recognizedText);
          break;

        case 'Excel':
          final excel = Excel.createExcel();
          final sheet = excel['OCR Data'];
          sheet.cell(CellIndex.indexByString('A1')).value =
              'OCR Export' as CellValue?;
          _recognizedText.split('\n').asMap().forEach((index, line) {
            sheet.cell(CellIndex.indexByString('A${index + 2}')).value =
                line as CellValue?;
          });
          path = '${dir.path}/$fileName.xlsx';
          await File(path).writeAsBytes(excel.encode()!);
          break;
      }

      _showSuccess('Exported to $format successfully!');
    } catch (e) {
      _showError('Export failed: ${e.toString()}');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Scanner'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _exportFile,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'PDF',
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf),
                  title: Text('Export to PDF'),
                ),
              ),
              const PopupMenuItem(
                value: 'TXT',
                child: ListTile(
                  leading: Icon(Icons.text_snippet),
                  title: Text('Export to Text'),
                ),
              ),
              const PopupMenuItem(
                value: 'Excel',
                child: ListTile(
                  leading: Icon(Icons.table_chart),
                  title: Text('Export to Excel'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isProcessing
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (_selectedImage != null)
                          Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.file(_selectedImage!),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SelectableText(
                              _recognizedText,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: () => _processImage(ImageSource.gallery),
                  child: const Icon(Icons.photo_library),
                ),
                FloatingActionButton(
                  onPressed: () => _processImage(ImageSource.camera),
                  child: const Icon(Icons.camera_alt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExportedFilesScreen extends StatefulWidget {
  const ExportedFilesScreen({super.key});

  @override
  _ExportedFilesScreenState createState() => _ExportedFilesScreenState();
}

class _ExportedFilesScreenState extends State<ExportedFilesScreen> {
  List<FileSystemEntity> _files = [];

  Future<void> _loadFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    setState(() {
      _files = dir.listSync().whereType<File>().toList();
    });
  }

  Future<void> _openFile(File file) async {
    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: ${result.message}')),
      );
    }
  }

  Future<void> _deleteFile(File file) async {
    await file.delete();
    await _loadFiles();
  }

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exported Files'),
      ),
      body: ListView.builder(
        itemCount: _files.length,
        itemBuilder: (context, index) {
          final file = _files[index] as File;
          return ListTile(
            leading: _getFileIcon(file.path),
            title: Text(File(file.path).uri.pathSegments.last),
            subtitle: Text(
              'Last modified: ${File(file.path).lastModifiedSync()}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteFile(file),
            ),
            onTap: () => _openFile(file),
          );
        },
      ),
    );
  }

  Widget _getFileIcon(String path) {
    if (path.endsWith('.pdf')) return const Icon(Icons.picture_as_pdf);
    if (path.endsWith('.txt')) return const Icon(Icons.text_snippet);
    if (path.endsWith('.xlsx')) return const Icon(Icons.table_chart);
    return const Icon(Icons.insert_drive_file);
  }
}
