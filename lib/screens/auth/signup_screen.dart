import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findom/screens/auth/login_screen.dart';
import 'package:findom/screens/auth/phone_verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    phoneController.text = "+91";
  }

  void signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final rawPhone = phoneController.text.trim();
    final phone = rawPhone.startsWith('+91') ? rawPhone : '+91$rawPhone';

    if (!RegExp(r'^\+91\d{10}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 10-digit Indian phone number")),
      );
      return;
    }

    if (email.isEmpty || password.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() => loading = true);
    try {
      // Register user with FirebaseAuth
      UserCredential userCredential = await AuthService.registerWithEmailPassword(email, password);

      final uid = userCredential.user?.uid;
      if (uid == null) throw Exception("User ID not found");

      // Store user details in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'phone': phone,
      });

      // Navigate to OTP screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PhoneVerificationScreen(phone: phone)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup failed: ${e.toString()}")),
        );
      }
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\+91\d{0,10}$')),
                LengthLimitingTextInputFormatter(13),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : signUp,
              child: loading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text("Sign Up"),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text("Login"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
