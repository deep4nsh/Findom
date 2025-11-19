import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class IncomeTaxCalculatorScreen extends StatefulWidget {
  const IncomeTaxCalculatorScreen({super.key});

  @override
  State<IncomeTaxCalculatorScreen> createState() => _IncomeTaxCalculatorScreenState();
}

class _IncomeTaxCalculatorScreenState extends State<IncomeTaxCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _hraController = TextEditingController();
  final _80cController = TextEditingController();
  final _80dController = TextEditingController();
  final _otherDeductionsController = TextEditingController();

  double _oldRegimeTax = 0;
  double _newRegimeTax = 0;
  bool _calculated = false;

  @override
  void dispose() {
    _incomeController.dispose();
    _hraController.dispose();
    _80cController.dispose();
    _80dController.dispose();
    _otherDeductionsController.dispose();
    super.dispose();
  }

  void _calculateTax() {
    if (_formKey.currentState!.validate()) {
      final income = double.tryParse(_incomeController.text) ?? 0;
      final hra = double.tryParse(_hraController.text) ?? 0;
      final section80c = double.tryParse(_80cController.text) ?? 0;
      final section80d = double.tryParse(_80dController.text) ?? 0;
      final otherDeductions = double.tryParse(_otherDeductionsController.text) ?? 0;

      setState(() {
        _oldRegimeTax = _calculateOldRegimeTax(income, hra, section80c, section80d, otherDeductions);
        _newRegimeTax = _calculateNewRegimeTax(income);
        _calculated = true;
      });
    }
  }

  double _calculateOldRegimeTax(double income, double hra, double s80c, double s80d, double other) {
    // Standard Deduction
    double taxableIncome = income - 50000;

    // Exemptions & Deductions
    double totalDeductions = hra + s80c + s80d + other;
    // Cap 80C at 1.5L
    if (s80c > 150000) totalDeductions = totalDeductions - s80c + 150000;
    
    taxableIncome -= totalDeductions;
    if (taxableIncome < 0) taxableIncome = 0;

    // Tax Slabs (Old Regime)
    // 0 - 2.5L : 0%
    // 2.5L - 5L : 5%
    // 5L - 10L : 20%
    // > 10L : 30%

    double tax = 0;
    if (taxableIncome > 1000000) {
      tax += (taxableIncome - 1000000) * 0.30;
      tax += 112500; // Tax for 10L
    } else if (taxableIncome > 500000) {
      tax += (taxableIncome - 500000) * 0.20;
      tax += 12500; // Tax for 5L
    } else if (taxableIncome > 250000) {
      tax += (taxableIncome - 250000) * 0.05;
    }

    // Rebate u/s 87A (Old Regime limit 5L)
    if (taxableIncome <= 500000) {
      tax = 0;
    }

    // Cess 4%
    tax += tax * 0.04;
    return tax;
  }

  double _calculateNewRegimeTax(double income) {
    // Standard Deduction (New Regime FY 24-25)
    double taxableIncome = income - 75000;
    if (taxableIncome < 0) taxableIncome = 0;

    // Tax Slabs (New Regime FY 24-25)
    // 0 - 3L : 0%
    // 3L - 7L : 5%
    // 7L - 10L : 10%
    // 10L - 12L : 15%
    // 12L - 15L : 20%
    // > 15L : 30%

    double tax = 0;
    if (taxableIncome > 1500000) {
      tax += (taxableIncome - 1500000) * 0.30;
      tax += 150000; // Tax for 15L
    } else if (taxableIncome > 1200000) {
      tax += (taxableIncome - 1200000) * 0.20;
      tax += 90000;
    } else if (taxableIncome > 1000000) {
      tax += (taxableIncome - 1000000) * 0.15;
      tax += 60000;
    } else if (taxableIncome > 700000) {
      tax += (taxableIncome - 700000) * 0.10;
      tax += 30000;
    } else if (taxableIncome > 300000) {
      tax += (taxableIncome - 300000) * 0.05;
    }

    // Rebate u/s 87A (New Regime limit 7L taxable income, effectively 7.75L gross)
    if (taxableIncome <= 700000) {
      tax = 0;
    }

    // Cess 4%
    tax += tax * 0.04;
    return tax;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income Tax Calculator', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Income Details'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _incomeController,
                label: 'Annual Income (Gross Salary)',
                icon: Icons.attach_money,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter income';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Deductions (Old Regime Only)'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _hraController,
                label: 'HRA Exemption',
                icon: Icons.house,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _80cController,
                label: 'Section 80C (Max 1.5L)',
                icon: Icons.savings,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _80dController,
                label: 'Section 80D (Health Ins.)',
                icon: Icons.medical_services,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _otherDeductionsController,
                label: 'Other Deductions',
                icon: Icons.more_horiz,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _calculateTax,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Calculate Tax',
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
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
      validator: validator,
    );
  }

  Widget _buildResultCard() {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final savings = (_oldRegimeTax - _newRegimeTax).abs();
    final betterRegime = _oldRegimeTax < _newRegimeTax ? "Old Regime" : "New Regime";
    final isSame = _oldRegimeTax == _newRegimeTax;

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
            'Tax Liability Comparison',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTaxColumn('Old Regime', _oldRegimeTax, currencyFormat),
              Container(width: 1, height: 50, color: Colors.grey[300]),
              _buildTaxColumn('New Regime', _newRegimeTax, currencyFormat),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          if (isSame)
            Text(
              "Both regimes have the same tax liability.",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            )
          else
            Column(
              children: [
                Text(
                  "Recommendation:",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  "$betterRegime is better",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  "You save ${currencyFormat.format(savings)}",
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.green[700]),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTaxColumn(String label, double amount, NumberFormat formatter) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 8),
        Text(
          formatter.format(amount),
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}
