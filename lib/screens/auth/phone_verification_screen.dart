import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String phone;
  const PhoneVerificationScreen({super.key, required this.phone});

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final otpController = TextEditingController();
  String? verificationId;
  bool codeSent = false;
  bool loading = false;

  void sendOTP() async {
    setState(() => loading = true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phone,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP Failed: ${e.message}")));
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          codeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
    setState(() => loading = false);
  }

  void verifyOTP() async {
    if (verificationId == null) return;

    setState(() => loading = true);
    try {
      await AuthService.linkPhoneNumberWithOTP(verificationId!, otpController.text.trim());
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Verification failed: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    sendOTP();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Phone")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (codeSent)
              TextField(controller: otpController, decoration: const InputDecoration(labelText: 'Enter OTP')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : verifyOTP,
              child: loading ? CircularProgressIndicator() : const Text("Verify OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
