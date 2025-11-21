import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:findom/screens/calculators/income_tax_calculator_screen.dart';
import 'package:findom/screens/calculators/gst_calculator_screen.dart';
import 'package:findom/screens/calculators/sip_calculator_screen.dart';

class CalculatorListScreen extends StatelessWidget {
  const CalculatorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Financial Calculators',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCalculatorItem(
            context,
            title: 'Income Tax Calculator',
            icon: Icons.calculate,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const IncomeTaxCalculatorScreen()),
              );
            },
          ),
          _buildCalculatorItem(
            context,
            title: 'GST Calculator',
            icon: Icons.percent,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GSTCalculatorScreen()),
              );
            },
          ),
          _buildCalculatorItem(
            context,
            title: 'SIP Calculator',
            icon: Icons.trending_up,
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SIPCalculatorScreen()),
              );
            },
          ),
          _buildCalculatorItem(
            context,
            title: 'EMI Calculator',
            icon: Icons.home,
            color: Colors.purple,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('EMI Calculator coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
