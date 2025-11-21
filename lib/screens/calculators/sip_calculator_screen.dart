import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class SIPCalculatorScreen extends StatefulWidget {
  const SIPCalculatorScreen({super.key});

  @override
  State<SIPCalculatorScreen> createState() => _SIPCalculatorScreenState();
}

class _SIPCalculatorScreenState extends State<SIPCalculatorScreen> {
  final _investmentController = TextEditingController();
  final _returnController = TextEditingController();
  final _yearsController = TextEditingController();

  double _investedAmount = 0;
  double _estReturns = 0;
  double _totalValue = 0;
  bool _calculated = false;

  void _calculateSIP() {
    final monthlyInvestment = double.tryParse(_investmentController.text) ?? 0;
    final expectedReturnRate = double.tryParse(_returnController.text) ?? 0;
    final years = double.tryParse(_yearsController.text) ?? 0;

    if (monthlyInvestment <= 0 || years <= 0) return;

    final months = years * 12;
    final monthlyRate = expectedReturnRate / 12 / 100;

    double futureValue = 0;
    if (monthlyRate == 0) {
      futureValue = monthlyInvestment * months;
    } else {
      futureValue = monthlyInvestment * (pow(1 + monthlyRate, months) - 1) * (1 + monthlyRate) / monthlyRate;
    }

    setState(() {
      _investedAmount = monthlyInvestment * months;
      _totalValue = futureValue;
      _estReturns = _totalValue - _investedAmount;
      _calculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SIP Calculator', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_investmentController, 'Monthly Investment', Icons.savings),
            const SizedBox(height: 16),
            _buildTextField(_returnController, 'Expected Return Rate (%)', Icons.percent),
            const SizedBox(height: 16),
            _buildTextField(_yearsController, 'Time Period (Years)', Icons.calendar_today),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _calculateSIP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Calculate',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
            if (_calculated) ...[
              const SizedBox(height: 32),
              _buildResultCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildResultCard() {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          _buildResultRow('Invested Amount', _investedAmount, currencyFormat),
          const SizedBox(height: 16),
          _buildResultRow('Est. Returns', _estReturns, currencyFormat, color: Colors.green),
          const Divider(height: 32),
          _buildResultRow('Total Value', _totalValue, currencyFormat, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, double amount, NumberFormat formatter, {Color? color, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          formatter.format(amount),
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 22 : 18,
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.blue[800] : (color ?? Colors.black87),
          ),
        ),
      ],
    );
  }
}
