import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:findom/services/tax_rules_service.dart';

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
  final _taxRulesService = TaxRulesService();

  double _oldRegimeTax = 0;
  double _newRegimeTax = 0;
  bool _calculated = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _incomeController.dispose();
    _hraController.dispose();
    _80cController.dispose();
    _80dController.dispose();
    _otherDeductionsController.dispose();
    super.dispose();
  }

  Future<void> _calculateTax() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final income = double.tryParse(_incomeController.text) ?? 0;
      final hra = double.tryParse(_hraController.text) ?? 0;
      final section80c = double.tryParse(_80cController.text) ?? 0;
      final section80d = double.tryParse(_80dController.text) ?? 0;
      final otherDeductions = double.tryParse(_otherDeductionsController.text) ?? 0;

      final rules = await _taxRulesService.getTaxRules();

      setState(() {
        _oldRegimeTax = _calculateOldRegimeTax(income, hra, section80c, section80d, otherDeductions, rules);
        _newRegimeTax = _calculateNewRegimeTax(income, rules);
        _calculated = true;
        _isLoading = false;
      });
    }
  }

  double _calculateOldRegimeTax(double income, double hra, double s80c, double s80d, double other, Map<String, dynamic> rules) {
    double taxableIncome = income - (rules['standard_deduction_old'] ?? 50000);

    double totalDeductions = hra + s80c + s80d + other;
    if (s80c > 150000) totalDeductions = totalDeductions - s80c + 150000;
    
    taxableIncome -= totalDeductions;
    if (taxableIncome < 0) taxableIncome = 0;

    double tax = 0;
    final slabs = List<Map<String, dynamic>>.from(rules['old_regime_slabs'] ?? []);
    
    double previousLimit = 0;
    for (var slab in slabs) {
      double limit = (slab['limit'] is int) ? (slab['limit'] as int).toDouble() : slab['limit'];
      double rate = (slab['rate'] is int) ? (slab['rate'] as int).toDouble() : slab['rate'];

      if (taxableIncome > previousLimit) {
        double taxableAmount = (taxableIncome > limit) ? (limit - previousLimit) : (taxableIncome - previousLimit);
        // Handle infinity
        if (limit == double.infinity) taxableAmount = taxableIncome - previousLimit;
        
        tax += taxableAmount * rate;
        previousLimit = limit;
      }
    }

    if (taxableIncome <= (rules['rebate_limit_old'] ?? 500000)) {
      tax = 0;
    }

    tax += tax * (rules['cess_rate'] ?? 0.04);
    return tax;
  }

  double _calculateNewRegimeTax(double income, Map<String, dynamic> rules) {
    double taxableIncome = income - (rules['standard_deduction_new'] ?? 75000);
    if (taxableIncome < 0) taxableIncome = 0;

    double tax = 0;
    final slabs = List<Map<String, dynamic>>.from(rules['new_regime_slabs'] ?? []);
    
    double previousLimit = 0;
    for (var slab in slabs) {
      double limit = (slab['limit'] is int) ? (slab['limit'] as int).toDouble() : slab['limit'];
      double rate = (slab['rate'] is int) ? (slab['rate'] as int).toDouble() : slab['rate'];

      if (taxableIncome > previousLimit) {
        double taxableAmount = (taxableIncome > limit) ? (limit - previousLimit) : (taxableIncome - previousLimit);
         // Handle infinity
        if (limit == double.infinity) taxableAmount = taxableIncome - previousLimit;

        tax += taxableAmount * rate;
        previousLimit = limit;
      }
    }

    if (taxableIncome <= (rules['rebate_limit_new'] ?? 700000)) {
      tax = 0;
    }

    tax += tax * (rules['cess_rate'] ?? 0.04);
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
                  onPressed: _isLoading ? null : _calculateTax,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
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
