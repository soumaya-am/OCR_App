import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

class OCRService {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/2.tflite');
      print('Modèle OCR chargé avec succès');
    } catch (e) {
      print('Erreur lors du chargement du modèle OCR : $e');
    }
  }

  Future<String> runOCR(Uint8List imageBytes) async {
    if (_interpreter == null) {
      await loadModel();
    }

    var input = _preprocessImage(imageBytes);
    var output = List.filled(100, 0).reshape([1, 100]);

    _interpreter!.run(input, output);

    return output.toString();
  }

  Uint8List _preprocessImage(Uint8List imageBytes) {
    return imageBytes;
  }
}
