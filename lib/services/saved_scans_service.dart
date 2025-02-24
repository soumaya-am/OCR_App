import 'package:flutter/foundation.dart';
import '../models/scan_model.dart';

class SavedScansService with ChangeNotifier {
  List<Scan> _scans = [];

  List<Scan> get scans => _scans;

  Future<void> searchScans(String query) async {
    // Implémentez la recherche
  }

  Future<void> toggleFavorite(String id) async {
    // Implémentez le favori
  }
}