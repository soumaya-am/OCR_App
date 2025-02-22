import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExportService {
  static Future<void> exportToExcel(Map<String, double> studentData) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Notes'];

    // Add the header row
    sheetObject.appendRow([
      TextCellValue('Nom'), 
      TextCellValue('Note')
    ]);

    // Add student data
    studentData.forEach((name, grade) {
      sheetObject.appendRow([
        TextCellValue(name), 
        DoubleCellValue(grade)
      ]);
    });

    // Get the storage directory
    Directory? directory = await getExternalStorageDirectory();
    String filePath = "${directory?.path}/notes_etudiants.xlsx";

    // Save the file
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    print("Fichier Excel sauvegardé : $filePath");
  }
}
