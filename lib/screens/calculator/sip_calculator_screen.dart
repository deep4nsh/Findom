import 'package:flutter/material.dart';
import 'package:findom/models/mutual_fund_model.dart';
import 'package:findom/services/mutual_fund_service.dart';
import 'package:findom/services/locator.dart';
import 'package:findom/widgets/app_bar.dart';
import 'package:findom/widgets/custom_card.dart';
import 'package:intl/intl.dart';

class SipCalculatorScreen extends StatefulWidget {
  const SipCalculatorScreen({super.key});

  @override
  State<SipCalculatorScreen> createState() => _SipCalculatorScreenState();
}

class _SipCalculatorScreenState extends State<SipCalculatorScreen> {
  final MutualFundService _mfService = locator<MutualFundService>();
  final TextEditingController _amountController = TextEditingController(text: '5000');
  final TextEditingController _durationController = TextEditingController(text: '5');
  
  List<MutualFundScheme> _allSchemes = [];
  MutualFundScheme? _selectedScheme;
  bool _isLoadingSchemes = true;
  bool _isCalculating = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSchemes();
  }

  Future<void> _loadSchemes() async {
    try {
      final schemes = await _mfService.getSchemes();
      setState(() {
        _allSchemes = schemes;
        _isLoadingSchemes = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load schemes: $e';
        _isLoadingSchemes = false;
      });
    }
  }

  Future<void> _calculateReturns() async {
    if (_selectedScheme == null) return;
    
    setState(() {
      _isCalculating = true;
      _error = null;
      _result = null;
    });

    try {
      final details = await _mfService.getSchemeDetails(_selectedScheme!.schemeCode);
      final amount = double.tryParse(_amountController.text) ?? 0;
      final duration = int.tryParse(_durationController.text) ?? 0;

      if (amount <= 0 || duration <= 0) {
        throw Exception('Invalid amount or duration');
      }

      final result = _mfService.calculateSipReturns(
        fundDetails: details,
        monthlyAmount: amount,
        durationYears: duration,
        sipDateDay: 1, // Default to 1st of month
      );

      setState(() {
        _result = result;
        _isCalculating = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Calculation failed: $e';
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'SIP Calculator'),
      body: _isLoadingSchemes
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  
                  Autocomplete<MutualFundScheme>(
                    displayStringForOption: (option) => option.schemeName,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<MutualFundScheme>.empty();
                      }
                      return _allSchemes.where((MutualFundScheme option) {
                        return option.schemeName
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (MutualFundScheme selection) {
                      setState(() {
                        _selectedScheme = selection;
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Search Mutual Fund',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Monthly Amount (₹)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Duration (Years)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedScheme == null || _isCalculating
                          ? null
                          : _calculateReturns,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isCalculating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Calculate Returns'),
                    ),
                  ),
                  
                  if (_result != null) ...[
                    const SizedBox(height: 32),
                    const Text(
                      'Result',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildResultRow(
                              'Total Invested',
                              '₹${NumberFormat('#,##,###').format(_result!['totalInvested'])}',
                            ),
                            const Divider(height: 24),
                            _buildResultRow(
                              'Current Value',
                              '₹${NumberFormat('#,##,###').format(_result!['currentValue'])}',
                              valueColor: Colors.green,
                              isBold: true,
                            ),
                            const Divider(height: 24),
                            _buildResultRow(
                              'Absolute Return',
                              '₹${NumberFormat('#,##,###').format(_result!['absoluteReturn'])}',
                              valueColor: _result!['absoluteReturn'] >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(height: 12),
                            _buildResultRow(
                              'Return %',
                              '${(_result!['returnPercentage'] as double).toStringAsFixed(2)}%',
                              valueColor: _result!['returnPercentage'] >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildResultRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
