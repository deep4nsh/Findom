import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign in with Google
  static Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception("Google Sign-In aborted by user.");
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google User Credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore
        final userDoc = await FirebaseFirestore.instance.collection('general_users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Create new user document
          await FirebaseFirestore.instance.collection('general_users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'fullName': user.displayName ?? '',
            'profilePictureUrl': user.photoURL,
            'phoneNumber': '', // To be verified later
            'isVerified': false,
            'createdAt': FieldValue.serverTimestamp(),
            'userType': 'general',
            'specializations': [],
            'education': '',
            'headline': '',
          });
        }
      }

      return userCredential;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      rethrow;
    }
  }

  // Logout the user
  static Future<void> logout() async {
    await _googleSignIn.signOut();
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
      
      // Update Firestore
      await FirebaseFirestore.instance.collection('general_users').doc(user.uid).update({
        'phoneNumber': user.phoneNumber,
        'isVerified': true,
      });
      
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
