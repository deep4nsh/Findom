import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class GSTCalculatorScreen extends StatefulWidget {
  const GSTCalculatorScreen({super.key});

  @override
  State<GSTCalculatorScreen> createState() => _GSTCalculatorScreenState();
}

class _GSTCalculatorScreenState extends State<GSTCalculatorScreen> {
  final _amountController = TextEditingController();
  double _gstRate = 18;
  bool _isInclusive = false; // Exclusive by default

  double _netPrice = 0;
  double _gstAmount = 0;
  double _totalPrice = 0;
  bool _calculated = false;

  void _calculateGST() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    setState(() {
      if (_isInclusive) {
        _totalPrice = amount;
        _netPrice = amount * (100 / (100 + _gstRate));
        _gstAmount = _totalPrice - _netPrice;
      } else {
        _netPrice = amount;
        _gstAmount = amount * (_gstRate / 100);
        _totalPrice = _netPrice + _gstAmount;
      }
      _calculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GST Calculator', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(),
            const SizedBox(height: 24),
            Text('GST Rate', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildRateSelector(),
            const SizedBox(height: 24),
            _buildTypeSelector(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _calculateGST,
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

  Widget _buildTextField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Amount',
        prefixIcon: const Icon(Icons.currency_rupee),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildRateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [5, 12, 18, 28].map((rate) {
        final isSelected = _gstRate == rate;
        return GestureDetector(
          onTap: () => setState(() => _gstRate = rate.toDouble()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '$rate%',
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<bool>(
            title: Text('Exclusive', style: GoogleFonts.poppins()),
            value: false,
            groupValue: _isInclusive,
            onChanged: (val) => setState(() => _isInclusive = val!),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        Expanded(
          child: RadioListTile<bool>(
            title: Text('Inclusive', style: GoogleFonts.poppins()),
            value: true,
            groupValue: _isInclusive,
            onChanged: (val) => setState(() => _isInclusive = val!),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

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
          _buildResultRow('Net Price', _netPrice, currencyFormat),
          const Divider(height: 30),
          _buildResultRow('GST Amount ($_gstRate%)', _gstAmount, currencyFormat),
          const Divider(height: 30),
          _buildResultRow('Total Price', _totalPrice, currencyFormat, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, double amount, NumberFormat formatter, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          formatter.format(amount),
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.blue[800] : Colors.black87,
          ),
        ),
      ],
    );
  }
}
