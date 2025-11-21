import 'package:cloud_firestore/cloud_firestore.dart';

class TaxRulesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Default fallback values (FY 2024-25)
  static const Map<String, dynamic> _defaultConfig = {
    'old_regime_slabs': [
      {'limit': 250000, 'rate': 0.0},
      {'limit': 500000, 'rate': 0.05},
      {'limit': 1000000, 'rate': 0.20},
      {'limit': double.infinity, 'rate': 0.30},
    ],
    'new_regime_slabs': [
      {'limit': 300000, 'rate': 0.0},
      {'limit': 700000, 'rate': 0.05},
      {'limit': 1000000, 'rate': 0.10},
      {'limit': 1200000, 'rate': 0.15},
      {'limit': 1500000, 'rate': 0.20},
      {'limit': double.infinity, 'rate': 0.30},
    ],
    'standard_deduction_old': 50000,
    'standard_deduction_new': 75000,
    'cess_rate': 0.04,
    'rebate_limit_old': 500000,
    'rebate_limit_new': 700000, // Taxable income limit for rebate
  };

  Future<Map<String, dynamic>> getTaxRules() async {
    try {
      final doc = await _firestore.collection('config').doc('tax_rules').get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!;
      }
    } catch (e) {
      print('Error fetching tax rules: $e');
    }
    return _defaultConfig;
  }
}
