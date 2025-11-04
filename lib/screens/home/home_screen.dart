import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/screens/auth/login_screen.dart';
import 'home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: model.isDarkMode ? Colors.grey[900] : const Color(0xFFF4F6FA),
            drawer: buildDrawer(context, model),
            appBar: buildAppBar(context, model),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchBar(),
                  carouselBanner(),
                  const SizedBox(height: 12),
                  checklistSection(context, model),
                  const SizedBox(height: 12),
                  financialCalendar(),
                  const SizedBox(height: 12),
                  progressTracker(),
                  const SizedBox(height: 12),
                  resourcesSection(),
                  const SizedBox(height: 12),
                  caProfileSection(),
                ],
              ),
            ),
            floatingActionButton: chatbotButton(context, model),
          );
        },
      ),
    );
  }

  Drawer buildDrawer(BuildContext context, HomeViewModel model) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3E4A89), Color(0xFF6C7ABF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Findom Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          buildDrawerTile(Icons.account_balance, 'Income Tax', () {}),
          buildDrawerTile(Icons.receipt_long, 'GST', () {}),
          buildDrawerTile(Icons.business_center, 'Business Formation', () {}),
          buildDrawerTile(Icons.attach_money, 'Salary Planning', () {}),
          buildDrawerTile(Icons.account_balance_wallet, 'Loans & Credits', () {}),
          buildDrawerTile(Icons.school, "Students' Corner", () {}),
          buildDrawerTile(Icons.health_and_safety, 'Insurance', () {}),
          buildDrawerTile(Icons.account_tree, 'Govt Schemes & Benefits', () {}),
          buildDrawerTile(Icons.newspaper, 'Financial News & Updates', () {}),
          buildDrawerTile(Icons.money_off, 'Debt Management', () {}),
          const Divider(),
          buildDrawerTile(Icons.person_outline, 'Profile', () {}),
          buildDrawerTile(Icons.logout, 'Logout', () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          }),
          const Divider(),
          darkModeToggle(model),
        ],
      ),
    );
  }

  Widget buildDrawerTile(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context, HomeViewModel model) {
    return AppBar(
      elevation: 1,
      backgroundColor: Colors.transparent,
      foregroundColor: model.isDarkMode ? Colors.white : Colors.black87,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile.png'),
              radius: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(model.getGreetingMessage(),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              Text(model.userName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo.shade700,
                  )),
            ],
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                model.setNotification(false);
              },
            ),
            if (model.hasNewNotification)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget searchBar() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: "Search tax info, deadlines...",
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );

  Widget carouselBanner() {
    return SizedBox(
      height: 150,
      child: PageView(
        children: [
          _carouselCard("📊 Budget Highlights 2025", Colors.indigo.shade100),
          _carouselCard("📢 GST Return Deadlines", Colors.orange.shade100),
          _carouselCard("💡 Save more on tax legally", Colors.green.shade100),
        ],
      ),
    );
  }

  Widget _carouselCard(String title, Color bgColor) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: bgColor,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Center(
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ),
  );

  Widget checklistSection(BuildContext context, HomeViewModel model) {
    final today = DateTime.now();
    final formattedDate = "${today.day}/${today.month}/${today.year}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("📝 Today's Checklist",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            Text(formattedDate, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 8),
        ...model.tasks.map((task) => Dismissible(
          key: Key(task),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            model.removeTask(task);
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: CheckboxListTile(
            title: Text(task),
            value: model.taskStatus[task] ?? false,
            onChanged: (value) {
              model.toggleTaskStatus(task, value);
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        )),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  final controller = TextEditingController();
                  return AlertDialog(
                    title: const Text("Add New Task"),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: "Task description"),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          model.addTask(controller.text.trim());
                          Navigator.pop(ctx);
                        },
                        child: const Text("Add"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Add Task"),
          ),
        )
      ],
    );
  }

  Widget financialCalendar() => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: const Icon(Icons.calendar_today, color: Colors.indigo),
      title: const Text("Next Deadline: 31st July"),
      subtitle: const Text("ITR Filing (AY 2025-26)"),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    ),
  );

  Widget progressTracker() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("🧭 Your Filing Journey",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      LinearProgressIndicator(
        value: 0.6,
        color: Colors.green,
        backgroundColor: Colors.grey.shade300,
      ),
      const SizedBox(height: 6),
      const Text("Step 3 of 5: Linked PAN to Aadhaar"),
    ],
  );

  Widget resourcesSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("📚 Recommended Resources",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 10),
      _resourceTile("📘 Tax Guide eBook", "PDF format", Icons.picture_as_pdf),
      _resourceTile("🎥 Budget 2025 Explainer", "Video from CA Gaurav", Icons.play_circle),
    ],
  );

  Widget _resourceTile(String title, String subtitle, IconData icon) =>
      ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () {},
      );

  Widget caProfileSection() => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: const CircleAvatar(
        backgroundImage: AssetImage('assets/images/ca_avatar.jpg'),
      ),
      title: const Text("CA Ramesh Mehta"),
      subtitle: const Text("Mehta & Associates | 12 years exp."),
      trailing: IconButton(
        icon: const Icon(Icons.phone),
        onPressed: () {},
      ),
    ),
  );

  Widget chatbotButton(BuildContext context, HomeViewModel model) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: const DecorationImage(
            image: AssetImage('assets/images/ca_mascot.png'),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget darkModeToggle(HomeViewModel model) {
    return SwitchListTile(
      value: model.isDarkMode,
      title: const Text("Dark Mode"),
      onChanged: (value) {
        model.saveDarkModePreference(value);
      },
    );
  }
}
