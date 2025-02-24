import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/scan_model.dart';
import '../services/scan_history_service.dart';

class ScanHistoryPage extends StatelessWidget {
  const ScanHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scanHistory = Provider.of<ScanHistoryService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Scans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearHistoryDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => scanHistory.loadScans(),
        child: ListView.builder(
          itemCount: scanHistory.scans.length,
          itemBuilder: (context, index) {
            final scan = scanHistory.scans[index];
            return Dismissible(
              key: Key(scan.id),
              background: Container(color: Colors.red),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) => _confirmDelete(context),
              onDismissed: (_) => scanHistory.deleteScan(scan.id),
              child: ListTile(
                leading: Image.network(scan.thumbnailUrl, width: 50),
                title: Text(scan.title),
                subtitle: Text(
                  scan.contentPreview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(scan.formattedDate),
                onTap: () => _showScanDetails(context, scan),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce scan ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showScanDetails(BuildContext context, Scan scan) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ScanDetailsSheet(scan: scan),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider l\'historique'),
        content: const Text('Supprimer tous les scans de l\'historique ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ScanHistoryService>(context, listen: false).clearAll();
              Navigator.pop(context);
            },
            child: const Text('Confirmer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ScanDetailsSheet extends StatelessWidget {
  final Scan scan;

  const ScanDetailsSheet({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(scan.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Text('Date: ${scan.formattedDateTime}'),
          const SizedBox(height: 20),
          Expanded(child: SingleChildScrollView(child: Text(scan.content))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Ouvrir'),
                onPressed: () => _openScan(context),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Partager'),
                onPressed: () => _shareScan(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openScan(BuildContext context) {
    // Implémentez la navigation vers la vue complète du scan
  }

  void _shareScan(BuildContext context) {
    // Implémentez le partage du scan
  }
}