import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findom/screens/auth/login_screen.dart';
import 'package:findom/screens/auth/phone_verification_screen.dart';
import 'package:findom/services/username_service.dart';
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
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  
  final _usernameService = UsernameService();
  bool loading = false;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    phoneController.text = "+91";
  }

  void signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final fullName = fullNameController.text.trim();
    final username = usernameController.text.trim();
    final rawPhone = phoneController.text.trim();
    final phone = rawPhone.startsWith('+91') ? rawPhone : '+91$rawPhone';

    if (!RegExp(r'^\+91\d{10}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 10-digit Indian phone number")),
      );
      return;
    }

    if (email.isEmpty || password.isEmpty || phone.isEmpty || fullName.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }
    
    final usernameValidation = _usernameService.validateUsername(username);
    if (usernameValidation != null) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(usernameValidation)),
      );
      return;
    }

    setState(() => loading = true);
    try {
      // 1. Check username availability first
      final isAvailable = await _usernameService.isUsernameAvailable(username);
      if (!isAvailable) {
        setState(() => _usernameError = "Username is already taken");
        throw Exception("Username is already taken");
      }

      // 2. Register user with FirebaseAuth
      UserCredential userCredential = await AuthService.registerWithEmailPassword(email, password);

      final uid = userCredential.user?.uid;
      if (uid == null) throw Exception("User ID not found");

      // 3. Reserve Username
      try {
        await _usernameService.reserveUsername(username, uid);
      } catch (e) {
        // Rollback: Delete created user if username reservation fails
        await userCredential.user?.delete();
        throw Exception("Failed to reserve username. Please try again.");
      }

      // 4. Store user details in Firestore (general_users collection)
      // Defaulting to 'general_users' for new signups
      await FirebaseFirestore.instance.collection('general_users').doc(uid).set({
        'uid': uid,
        'email': email,
        'phoneNumber': phone,
        'fullName': fullName,
        'username': username,
        'userType': 'general',
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': false,
        'specializations': [],
        'education': '',
        'headline': '',
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
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixText: '@',
                  errorText: _usernameError,
                ),
                onChanged: (_) {
                  if (_usernameError != null) setState(() => _usernameError = null);
                },
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
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
      ),
    );
  }
}

