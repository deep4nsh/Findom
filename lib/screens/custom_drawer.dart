import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final Function(String) onSelectCategory;

  const CustomDrawer({super.key, required this.onSelectCategory});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Column(
        children: [
          // Top user header
          UserAccountsDrawerHeader(
            accountName: Text("Deepansh Gupta"),
            accountEmail: Text("deepansh@email.com"),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/profile.jpg'), // replace with NetworkImage or default
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),

          // List items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                buildDrawerItem(Icons.account_balance, "Income Tax"),
                buildDrawerItem(Icons.receipt_long, "GST"),
                buildDrawerItem(Icons.business_center, "Business Formation"),
                buildDrawerItem(Icons.payments, "Salary Planning"),
                buildDrawerItem(Icons.credit_score, "Loans & Credits"),
                buildDrawerItem(Icons.school, "Students' Corner"),
                buildDrawerItem(Icons.health_and_safety, "Insurance"),
                buildDrawerItem(Icons.account_balance_wallet, "Government Schemes & Benefits"),
                buildDrawerItem(Icons.newspaper, "Financial News & Updates"),
                buildDrawerItem(Icons.money_off_csred, "Debt Management"),
              ],
            ),
          ),

          // Optional: Footer or version info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'v1.0.0',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
            ),
          )
        ],
      ),
    );
  }

  Widget buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => onSelectCategory(title),
    );
  }
}
