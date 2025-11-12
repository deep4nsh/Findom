import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:findom/app/root_nav.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Welcome to Findom",
      "desc": "Master your finances with ease and confidence.",
      "image": "assets/images/onboard1.png"
    },
    {
      "title": "Financials Simplified!",
      "desc": "Get financial wisdom with Findom.",
      "image": "assets/images/onboard2.png"
    },
    {
      "title": "Do more than just finance.",
      "desc": "Plan and learn your future.",
      "image": "assets/images/onboard3.png"
    },
  ];

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_shown', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RootNav()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: onboardingData.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Fullscreen Background Image
              Image.asset(
                onboardingData[index]['image']!,
                fit: BoxFit.cover,
              ),

              // Overlay with color filter (optional for better readability)
              Container(
                color: Colors.black.withAlpha(102),
              ),

              // Content Overlay
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),
                      Text(
                        onboardingData[index]['title']!,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        onboardingData[index]['desc']!,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(flex: 4),
                      ElevatedButton(
                        onPressed: index == onboardingData.length - 1
                            ? _finishOnboarding
                            : _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          index == onboardingData.length - 1
                              ? "Get Started"
                              : "Next",
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
