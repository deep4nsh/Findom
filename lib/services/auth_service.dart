import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register with Email & Password
  static Future<UserCredential> registerWithEmailPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  // Logout the user
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // Link Phone Number with OTP
  static Future<void> linkPhoneNumberWithOTP(String verificationId, String smsCode) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("No user is currently signed in.");
    }

    try {
      PhoneAuthCredential phoneCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await user.linkWithCredential(phoneCredential);
      debugPrint("✅ Phone number linked successfully.");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        debugPrint("⚠️ This phone number is already linked to the account.");
      } else if (e.code == 'credential-already-in-use') {
        debugPrint("❌ This phone number is already used by another account.");
        throw Exception("This phone number is already in use.");
      } else {
        debugPrint("❌ Linking failed: ${e.message}");
        throw Exception("Failed to link phone number: ${e.message}");
      }
    } catch (e) {
      debugPrint("❌ Unknown error during linking: $e");
      rethrow;
    }
  }
}
