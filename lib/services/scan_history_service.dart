import 'package:flutter/foundation.dart';
import '../models/scan_model.dart';

class ScanHistoryService with ChangeNotifier {
  List<Scan> _scans = [];

  List<Scan> get scans => _scans;

  Future<void> loadScans() async {
    // Implémentez le chargement depuis Firestore/local storage
  }

  Future<void> deleteScan(String id) async {
    _scans.removeWhere((scan) => scan.id == id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _scans = [];
    notifyListeners();
  }
}