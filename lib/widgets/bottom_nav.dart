import 'package:flutter/material.dart';
import 'package:findom/localization/app_localizations.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key, 
    required this.currentIndex, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Using localization if available, otherwise fallback to hardcoded strings
    // Note: AppLocalizations might need to be initialized properly in main.dart
    final loc = AppLocalizations.of(context);

    return BottomNavigationBar(
      backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined), 
          activeIcon: const Icon(Icons.home), 
          label: loc?.translate('home') ?? 'Home',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.school_outlined), 
          activeIcon: const Icon(Icons.school), 
          label: loc?.translate('modules') ?? 'Learn', // Mapping 'modules' to Learn tab for now based on icon
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people_outline), 
          activeIcon: const Icon(Icons.people), 
          label: 'Connect', // No key in json yet, using hardcoded
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.work_outline), 
          activeIcon: const Icon(Icons.work), 
          label: 'Jobs', // No key in json yet
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline), 
          activeIcon: const Icon(Icons.person), 
          label: loc?.translate('profile') ?? 'Me',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    );
  }
}
