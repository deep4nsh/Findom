import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:findom/models/module_content.dart';

class ModuleDetailScreen extends StatelessWidget {
  final ModuleContent module;

  const ModuleDetailScreen({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          module.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              module.description,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            ...module.sections.map((section) => _buildSection(section)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ModuleSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.heading,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            section.content,
            style: GoogleFonts.poppins(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
