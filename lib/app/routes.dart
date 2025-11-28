import 'package:flutter/material.dart';
import 'package:findom/screens/reminders/reminder_screen.dart';
import 'package:findom/screens/explore/explore_screen.dart';
import 'package:findom/screens/calculator/sip_calculator_screen.dart';

class Routes {
  static const String reminders = '/reminders';
  static const String explore = '/explore';
  static const String sipCalculator = '/sip-calculator';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      reminders: (context) => const ReminderScreen(),
      explore: (context) => const ExploreScreen(),
      sipCalculator: (context) => const SipCalculatorScreen(),
    };
  }
}
