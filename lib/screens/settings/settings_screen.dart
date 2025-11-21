import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:findom/services/theme_provider.dart';
import 'package:findom/screens/auth/login_screen.dart'; // Assuming this exists or will be used for nav after logout

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('General'),
          _buildSettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (val) {
                themeProvider.toggleTheme(val);
              },
            ),
          ),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              // TODO: Implement Language Selection
            },
          ),
          _buildSectionHeader('Account'),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              // TODO: Navigate to Edit Profile Screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile coming soon!')),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              // TODO: Navigate to Notification Settings
            },
          ),
          _buildSectionHeader('Support'),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // TODO: Navigate to Help
            },
          ),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            color: Colors.red,
            onTap: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await FirebaseAuth.instance.signOut();
              // Navigation to login is usually handled by the auth state stream wrapper in AppShell or main.dart
              // But if we need to force it:
              // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            },
            child: Text('Logout', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: color ?? Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: GoogleFonts.poppins(fontSize: 12))
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
