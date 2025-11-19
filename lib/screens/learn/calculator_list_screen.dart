import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:findom/screens/calculators/income_tax_calculator_screen.dart';

class CalculatorListScreen extends StatelessWidget {
  const CalculatorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calculators = [
      {'title': 'Income Tax Calculator', 'icon': Icons.calculate},
      {'title': 'GST Calculator', 'icon': Icons.percent},
      {'title': 'SIP Calculator', 'icon': Icons.savings},
      {'title': 'EMI Calculator', 'icon': Icons.home},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calculators',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: calculators.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final calc = calculators[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(calc['icon'] as IconData, color: Colors.blue),
            ),
            title: Text(
              calc['title'] as String,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (calc['title'] == 'Income Tax Calculator') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IncomeTaxCalculatorScreen()),
                );
              } else {
                // TODO: Navigate to other calculators
              }
            },
          );
        },
      ),
    );
  }
}
