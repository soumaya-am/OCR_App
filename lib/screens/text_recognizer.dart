import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr_application2/screens/export_service.dart';
import 'package:ocr_application2/screens/grading_service.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:ocr_application2/screens/ocr_service.dart';

class TextRecognizerPage extends StatefulWidget {
  const TextRecognizerPage({super.key});

  @override
  State<TextRecognizerPage> createState() => _TextRecognizerPageState();
}

class _TextRecognizerPageState extends State<TextRecognizerPage> {
  final OCRService _ocrService = OCRService();
  File? _image;
  String _recognizedText = "Aucun texte détecté";
  double _assignedGrade = 0.0;

  @override
  void initState() {
    super.initState();
    _ocrService.loadModel();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      Uint8List imageBytes = await _image!.readAsBytes();
      String recognizedName = await _ocrService.runOCR(imageBytes);
      double assignedGrade = GradingService.assignGrade(recognizedName);

      setState(() {
        _recognizedText = "Nom: $recognizedName";
        _assignedGrade = assignedGrade;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reconnaissance OCR")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _image != null ? Image.file(_image!) : const Text("Aucune image sélectionnée"),
          ElevatedButton(onPressed: _pickImage, child: const Text("Choisir une image")),
          const SizedBox(height: 20),
          Text("Texte détecté : $_recognizedText"),
          Text("Note attribuée : $_assignedGrade"),
          ElevatedButton(
            onPressed: () {
              ExportService.exportToExcel(GradingService.studentGrades);
            },
            child: const Text("Exporter en Excel"),
          ),
        ],
      ),
    );
  }
}
