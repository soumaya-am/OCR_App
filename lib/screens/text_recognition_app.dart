import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';


class TextRecognitionApp extends StatefulWidget {
  const TextRecognitionApp({super.key});

  @override
  _TextRecognitionAppState createState() => _TextRecognitionAppState();
}

class _TextRecognitionAppState extends State<TextRecognitionApp> {
  final ImagePicker _picker = ImagePicker();
  String _recognizedText = '';

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImageAndRecognizeText() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final InputImage inputImage = InputImage.fromFile(imageFile);

      // Initialize the TextRecognizer
      final textRecognizer = TextRecognizer();

      try {
        final RecognizedText recognizedText =
            await textRecognizer.processImage(inputImage);

        setState(() {
          _recognizedText = recognizedText.text;
        });
      } catch (e) {
        print('Error recognizing text: $e');
      } finally {
        await textRecognizer.close();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Recognition'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImageAndRecognizeText,
              child: Text('Pick Image and Recognize Text'),
            ),
            SizedBox(height: 20),
            Text(
              'Recognized Text:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              _recognizedText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: TextRecognitionApp()));
