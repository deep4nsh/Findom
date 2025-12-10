import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class EMICalculatorScreen extends StatefulWidget {
  const EMICalculatorScreen({super.key});

  @override
  State<EMICalculatorScreen> createState() => _EMICalculatorScreenState();
}

class _EMICalculatorScreenState extends State<EMICalculatorScreen> {
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();
  final _tenureController = TextEditingController();

  double _loanAmount = 0;
  double _interestRate = 0;
  double _loanTenureYears = 0;
  
  double _monthlyEMI = 0;
  double _totalInterest = 0;
  double _totalPayment = 0;
  
  bool _calculated = false;

  void _calculateEMI() {
    double principal = double.tryParse(_amountController.text) ?? 0;
    double rate = double.tryParse(_rateController.text) ?? 0;
    double tenureYears = double.tryParse(_tenureController.text) ?? 0;

    if (principal <= 0 || rate <= 0 || tenureYears <= 0) return;

    // EMI Calculation: E = P * r * (1+r)^n / ((1+r)^n - 1)
    // where P = Principal, r = monthly interest rate, n = tenure in months
    
    double monthlyRate = rate / 12 / 100;
    double tenureMonths = tenureYears * 12;

    double emi = (principal * monthlyRate * pow(1 + monthlyRate, tenureMonths)) / 
                 (pow(1 + monthlyRate, tenureMonths) - 1);
                 
    double totalPayment = emi * tenureMonths;
    double totalInterest = totalPayment - principal;

    setState(() {
      _loanAmount = principal;
      _interestRate = rate;
      _loanTenureYears = tenureYears;
      _monthlyEMI = emi;
      _totalInterest = totalInterest;
      _totalPayment = totalPayment;
      _calculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EMI Calculator', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_amountController, 'Loan Amount', Icons.monetization_on),
            const SizedBox(height: 16),
            _buildTextField(_rateController, 'Interest Rate (% p.a.)', Icons.percent),
            const SizedBox(height: 16),
            _buildTextField(_tenureController, 'Loan Tenure (Years)', Icons.calendar_today),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _calculateEMI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Calculate EMI',
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.purple[700]),
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
          Text(
            'Monthly EMI',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(_monthlyEMI),
            style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.purple[800]),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildResultRow('Principal Amount', _loanAmount, currencyFormat),
          const SizedBox(height: 12),
          _buildResultRow('Total Interest', _totalInterest, currencyFormat, color: Colors.red[700]),
          const SizedBox(height: 12),
          _buildResultRow('Total Payabale', _totalPayment, currencyFormat, isBold: true),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, double amount, NumberFormat formatter, {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        Text(
          formatter.format(amount),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
