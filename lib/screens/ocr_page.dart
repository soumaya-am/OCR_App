// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';

// class OCRPage extends StatefulWidget {
//   const OCRPage({super.key});

//   @override
//   State<OCRPage> createState() => _OCRPageState();
// }

// class _OCRPageState extends State<OCRPage> {
//   File? _selectedImage;
//   String _extractedText = "Aucun texte détecté.";
//   final ImagePicker _imagePicker = ImagePicker();

//   // Fonction pour demander les permissions
//   Future<bool> _requestPermissions() async {
//     var cameraStatus = await Permission.camera.request();
//     var storageStatus = await Permission.storage.request();

//     if (cameraStatus.isGranted && storageStatus.isGranted) {
//       return true;
//     } else {
//       _showPermissionDeniedDialog();
//       return false;
//     }
//   }

//   // Fonction pour afficher un dialogue si les permissions sont refusées
//   void _showPermissionDeniedDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Permissions refusées"),
//         content: const Text(
//             "L'application a besoin des permissions pour accéder à la caméra et à la galerie."),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }

//   // Fonction pour sélectionner une image
//   Future<void> _pickImage() async {
//     bool hasPermissions = await _requestPermissions();
//     if (!hasPermissions) return;

//     final XFile? pickedFile =
//         await _imagePicker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//       _performOCR(_selectedImage!);
//     }
//   }

//   // Fonction pour exécuter l'OCR
//   Future<void> _performOCR(File image) async {
//     final inputImage = InputImage.fromFile(image);
//     final textRecognizer = GoogleMlKit.vision.textRecognizer();

//     try {
//       final RecognizedText recognizedText =
//           await textRecognizer.processImage(inputImage);

//       setState(() {
//         _extractedText = recognizedText.text;
//       });
//     } catch (e) {
//       setState(() {
//         _extractedText = "Erreur lors de l'analyse de l'image.";
//       });
//     }

//     textRecognizer.close();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('OCR Page'),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           if (_selectedImage != null)
//             Image.file(_selectedImage!)
//           else
//             const Icon(
//               Icons.image,
//               size: 100,
//               color: Colors.grey,
//             ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _pickImage,
//             child: const Text('Choisir une image'),
//           ),
//           const SizedBox(height: 20),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Text(
//               _extractedText,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class OCRPage extends StatefulWidget {
  const OCRPage({super.key});

  @override
  State<OCRPage> createState() => _OCRPageState();
}

class _OCRPageState extends State<OCRPage> {
  File? _selectedImage;
  String _extractedText = "Aucun texte détecté.";
  final ImagePicker _imagePicker = ImagePicker();

  // Fonction pour demander les permissions
  Future<bool> _requestPermissions() async {
    var cameraStatus = await Permission.camera.request();
    var storageStatus = await Permission.storage.request();

    if (cameraStatus.isGranted && storageStatus.isGranted) {
      return true;
    } else {
      _showPermissionDeniedDialog();
      return false;
    }
  }

  // Fonction pour afficher un dialogue si les permissions sont refusées
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permissions refusées"),
        content: const Text(
            "L'application a besoin des permissions pour accéder à la caméra et à la galerie."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Fonction pour prendre une photo
  Future<void> _takePhoto() async {
    bool hasPermissions = await _requestPermissions();
    if (!hasPermissions) return;

    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      _performOCR(_selectedImage!);
    }
  }

  // Fonction pour exécuter l'OCR
  Future<void> _performOCR(File image) async {
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      setState(() {
        _extractedText = recognizedText.text;
      });
      // Sauvegarder le texte extrait dans un fichier
      _saveTextToFile(_extractedText);
    } catch (e) {
      setState(() {
        _extractedText = "Erreur lors de l'analyse de l'image.";
      });
    }

    textRecognizer.close();
  }

  // Fonction pour sauvegarder le texte extrait dans un fichier
  Future<void> _saveTextToFile(String text) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/extracted_text.txt');
    await file.writeAsString(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_selectedImage != null)
            Image.file(_selectedImage!)
          else
            const Icon(
              Icons.camera_alt,
              size: 100,
              color: Colors.grey,
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _takePhoto,
            child: const Text('Prendre une photo'),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _extractedText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
