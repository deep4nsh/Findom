import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:findom/screens/learn/calculator_list_screen.dart';
import 'package:findom/models/module_content.dart';
import 'package:findom/screens/learn/module_detail_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Learn Finance',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Tools'),
            const SizedBox(height: 12),
            _buildToolsGrid(context),
            const SizedBox(height: 24),
            _buildSectionHeader('Modules'),
            const SizedBox(height: 12),
            _buildModulesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildToolsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildToolCard(
            context,
            icon: Icons.calculate_outlined,
            title: 'Calculators',
            color: Colors.blue.shade100,
            iconColor: Colors.blue.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalculatorListScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildToolCard(
            context,
            icon: Icons.calendar_today_outlined,
            title: 'Due Dates',
            color: Colors.orange.shade100,
            iconColor: Colors.orange.shade700,
            onTap: () {
              // TODO: Navigate to Due Dates
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesList() {
    final modules = ModuleContent.sampleModules;
    // Map module IDs to icons
    final Map<String, IconData> moduleIcons = {
      'income_tax_basics': Icons.account_balance_wallet,
      'gst_explained': Icons.receipt_long,
      'business_registration': Icons.business,
      'investment_101': Icons.trending_up,
    };

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final module = modules[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(moduleIcons[module.id] ?? Icons.book, color: Colors.black87),
            ),
            title: Text(
              module.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModuleDetailScreen(module: module),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
