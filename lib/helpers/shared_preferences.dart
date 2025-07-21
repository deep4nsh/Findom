import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String _onboardingShownKey = 'onboarding_shown';

  /// Save onboarding shown flag
  static Future<void> setOnboardingShown(bool shown) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingShownKey, shown);
  }

  /// Get onboarding shown flag
  static Future<bool> isOnboardingShown() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingShownKey) ?? false;
  }

  /// Optional: Clear onboarding (useful for testing)
  static Future<void> clearOnboarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingShownKey);
  }
}
