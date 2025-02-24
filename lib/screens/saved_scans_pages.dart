import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/scan_model.dart';
import '../services/saved_scans_service.dart';

class SavedScansPage extends StatelessWidget {
  const SavedScansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final savedScans = Provider.of<SavedScansService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scans Sauvegardés'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: savedScans.scans.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemCount: savedScans.scans.length,
              itemBuilder: (context, index) => _buildScanCard(savedScans.scans[index]),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showSaveOptions(context),
      ),
    );
  }

  Widget _buildScanCard(Scan scan) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              scan.thumbnailUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  scan.formattedDate,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () => _toggleFavorite(scan.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteScan(scan.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'Aucun scan sauvegardé',
            style: TextStyle(color: Colors.grey[600], fontSize: 18),
          ),
          const SizedBox(height: 10),
          const Text('Appuyez sur le + pour sauvegarder un scan'),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher un scan'),
        content: TextField(
          decoration: const InputDecoration(hintText: 'Mot-clé...'),
          onChanged: (query) => _searchScans(context, query),
        ),
      ),
    );
  }

  void _searchScans(BuildContext context, String query) {
    Provider.of<SavedScansService>(context, listen: false).searchScans(query);
  }

  void _showSaveOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.scanner),
              title: const Text('Nouveau scan'),
              onTap: () => _navigateToScanner(context),
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Créer un dossier'),
              onTap: () => _createNewFolder(context),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScanner(BuildContext context) {
    Navigator.pushNamed(context, '/scanner');
  }

  void _createNewFolder(BuildContext context) {
    // Implémentez la création de dossier
  }

  void _toggleFavorite(String scanId) {
    // Implémentez le favori
  }

  void _deleteScan(String scanId) {
    // Implémentez la suppression
  }
}