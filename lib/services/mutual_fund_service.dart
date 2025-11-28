import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:findom/models/mutual_fund_model.dart';

class MutualFundService {
  static const String _baseUrl = 'https://api.mfapi.in/mf';

  Future<List<MutualFundScheme>> getSchemes() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MutualFundScheme.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load schemes');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }

  Future<MutualFundDetails> getSchemeDetails(int schemeCode) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$schemeCode'));
      if (response.statusCode == 200) {
        return MutualFundDetails.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load scheme details');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }

  Map<String, dynamic> calculateSipReturns({
    required MutualFundDetails fundDetails,
    required double monthlyAmount,
    required int durationYears,
    required int sipDateDay, // e.g., 1 for 1st of month
  }) {
    final now = DateTime.now();
    final startDate = DateTime(now.year - durationYears, now.month, now.day);
    
    // Sort data by date ascending (API returns descending usually)
    final dateFormat = DateFormat('dd-MM-yyyy');
    final sortedNavs = List<NavData>.from(fundDetails.data);
    sortedNavs.sort((a, b) => dateFormat.parse(a.date).compareTo(dateFormat.parse(b.date)));

    double totalUnits = 0;
    double totalInvested = 0;
    int installments = 0;

    // Find the first valid SIP date on or after startDate
    DateTime currentSipDate = DateTime(startDate.year, startDate.month, sipDateDay);
    if (currentSipDate.isBefore(startDate)) {
      currentSipDate = DateTime(startDate.year, startDate.month + 1, sipDateDay);
    }

    while (currentSipDate.isBefore(now)) {
      // Find NAV for this date or closest previous date
      double? nav;
      
      // Look for exact date match first
      final dateStr = dateFormat.format(currentSipDate);
      final exactMatch = sortedNavs.where((e) => e.date == dateStr);
      
      if (exactMatch.isNotEmpty) {
        nav = exactMatch.first.nav;
      } else {
        // Find closest previous date
        final previousDates = sortedNavs.where((e) {
          final d = dateFormat.parse(e.date);
          return d.isBefore(currentSipDate);
        });
        
        if (previousDates.isNotEmpty) {
          nav = previousDates.last.nav;
        }
      }

      if (nav != null && nav > 0) {
        final units = monthlyAmount / nav;
        totalUnits += units;
        totalInvested += monthlyAmount;
        installments++;
      }

      // Move to next month
      if (currentSipDate.month == 12) {
        currentSipDate = DateTime(currentSipDate.year + 1, 1, sipDateDay);
      } else {
        currentSipDate = DateTime(currentSipDate.year, currentSipDate.month + 1, sipDateDay);
      }
    }

    final currentNav = sortedNavs.last.nav;
    final currentValue = totalUnits * currentNav;
    final absoluteReturn = currentValue - totalInvested;
    final returnPercentage = (absoluteReturn / totalInvested) * 100;

    // Simple CAGR approximation
    // CAGR = (Current Value / Principal) ^ (1/Time) - 1
    // Note: For SIP, XIRR is better, but this is a simple approximation for now
    // Or we can just show absolute returns
    
    return {
      'totalInvested': totalInvested,
      'currentValue': currentValue,
      'absoluteReturn': absoluteReturn,
      'returnPercentage': returnPercentage,
      'installments': installments,
      'currentNav': currentNav,
    };
  }
}
