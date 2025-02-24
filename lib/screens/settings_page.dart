import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Préférences'),
          _buildThemeSwitch(context),
          _buildLanguageSelector(context),
          _buildSectionHeader('Notifications'),
          _buildNotificationSwitch('Nouvelles fonctionnalités', true),
          _buildNotificationSwitch('Mises à jour', false),
          _buildSectionHeader('Sécurité'),
          _buildSecurityTile('Changer le mot de passe'),
          _buildSecurityTile('Authentification à deux facteurs'),
          const SizedBox(height: 30),
          _buildAppInfo(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildThemeSwitch(BuildContext context) {
    return SwitchListTile(
      title: const Text('Mode sombre'),
      value: Provider.of<ThemeProvider>(context).isDarkMode,
      onChanged: (value) => Provider.of<ThemeProvider>(context, listen: false)
          .toggleTheme(value),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return ListTile(
      title: const Text('Langue'),
      trailing: DropdownButton<String>(
        value: 'Français',
        items: const [
          DropdownMenuItem(value: 'Français', child: Text('Français')),
          DropdownMenuItem(value: 'English', child: Text('English')),
        ],
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildNotificationSwitch(String title, bool value) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (newValue) {},
    );
  }

  Widget _buildSecurityTile(String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _buildAppInfo() {
    return const Column(
      children: [
        Text('Version 1.0.0'),
        Text('© 2024 OCR App'),
      ],
    );
  }
}

// Ajoutez ce Provider dans votre main.dart
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}