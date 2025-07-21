import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/services/theme_provider.dart';
import 'package:findom/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool hasNewNotification = true;
  bool isDarkMode = false;
  String userName = "Loading...";
  @override
  void initState() {
    super.initState();
    fetchUserName();
    loadDarkModePreference();
  }

  Future<void> loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> saveDarkModePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }


  String getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
  Future<void> fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        userName = doc['name'] ?? 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : const Color(0xFFF4F6FA),
      drawer: Drawer(
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
              child: Text(
                'Navigation',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {},
            ),
            darkModeToggle()
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/profile.jpg'),
                radius: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(getGreetingMessage(),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                Text(userName,
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
                  setState(() {
                    hasNewNotification = false;
                  });
                },
              ),
              if (hasNewNotification)
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            searchBar(),
            carouselBanner(),
            const SizedBox(height: 8),
            quickStats(),
            const SizedBox(height: 12),
            checklistSection(),
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
      floatingActionButton: chatbotButton(),
    );
  }

  // -------------------------------------------
  // Components below
  // -------------------------------------------

  Widget searchBar() {
    return Padding(
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
  }

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

  Widget _carouselCard(String title, Color bgColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: bgColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Center(
        child: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget quickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statCard("Portfolio", "₹1,20,000", Icons.account_balance_wallet),
        _statCard("Today’s Gain", "+₹2,300", Icons.trending_up),
        _statCard("Pending", "₹14,000", Icons.hourglass_bottom),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.indigo.shade50,
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: Colors.indigo),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget checklistSection() {
    final tasks = ["Submit Form 10E", "Pay Advance Tax", "File GSTR-3B"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("📝 Today's Checklist",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...tasks.map((task) => CheckboxListTile(
          title: Text(task),
          value: false,
          onChanged: (_) {},
          controlAffinity: ListTileControlAffinity.leading,
        )),
      ],
    );
  }

  Widget financialCalendar() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Colors.indigo),
        title: const Text("Next Deadline: 31st July"),
        subtitle: const Text("ITR Filing (AY 2025-26)"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }

  Widget progressTracker() {
    return Column(
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
  }

  Widget resourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("📚 Recommended Resources",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        _resourceTile("📘 Tax Guide eBook", "PDF format", Icons.picture_as_pdf),
        _resourceTile("🎥 Budget 2025 Explainer", "Video from CA Gaurav",
            Icons.play_circle),
      ],
    );
  }

  Widget _resourceTile(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {},
    );
  }

  Widget caProfileSection() {
    return Card(
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
  }

  Widget chatbotButton() {
    return FloatingActionButton.extended(
      onPressed: () {},
      icon: const Icon(Icons.chat),
      label: const Text("Ask Your CA"),
      backgroundColor: Colors.indigo,
    );
  }

  Widget darkModeToggle() {
    return SwitchListTile(
      value: isDarkMode,
      title: const Text("Dark Mode"),
      onChanged: (value) {
        setState(() {
          isDarkMode = value;
        });
      },
    );
  }
}
