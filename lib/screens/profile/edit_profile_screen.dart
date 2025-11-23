import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findom/models/user_profile_model.dart';
import 'package:findom/services/auth_service.dart';
import 'package:findom/services/username_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameService = UsernameService();
  
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _headlineController;
  late TextEditingController _educationController;
  late TextEditingController _specializationController;
  late TextEditingController _phoneController;
  List<String> _specializations = [];
  
  bool _isCheckingUsername = false;
  String? _usernameError;
  bool _isVerifyingPhone = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _usernameController = TextEditingController(text: widget.profile.username);
    _headlineController = TextEditingController(text: widget.profile.headline);
    _educationController = TextEditingController(text: widget.profile.education);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _specializationController = TextEditingController();
    _specializations = List<String>.from(widget.profile.specializations);
  }
  
  String _getCollectionForUserType(UserType userType) {
    return 'general_users'; // Unified collection
  }

  Future<void> _verifyPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a phone number")),
      );
      return;
    }

    // Basic validation for Indian numbers
    final formattedPhone = phone.startsWith('+91') ? phone : '+91$phone';
    if (!RegExp(r'^\+91\d{10}$').hasMatch(formattedPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 10-digit Indian phone number")),
      );
      return;
    }

    setState(() => _isVerifyingPhone = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (Android only)
          await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
          _updatePhoneStatus(formattedPhone);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isVerifyingPhone = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${e.message}")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _isVerifyingPhone = false);
          _showOtpDialog(verificationId, formattedPhone);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
      );
    } catch (e) {
      setState(() => _isVerifyingPhone = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showOtpDialog(String verificationId, String phone) {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Enter OTP"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Enter the OTP sent to $phone"),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "OTP"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final smsCode = otpController.text.trim();
              if (smsCode.isNotEmpty) {
                try {
                  await AuthService.linkPhoneNumberWithOTP(verificationId, smsCode);
                  if (mounted) {
                    Navigator.pop(context);
                    _updatePhoneStatus(phone);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Invalid OTP: $e")),
                    );
                  }
                }
              }
            },
            child: const Text("Verify"),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePhoneStatus(String phone) async {
    await FirebaseFirestore.instance.collection('general_users').doc(widget.profile.uid).update({
      'phoneNumber': phone,
      'isVerified': true,
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number verified successfully!")),
      );
      setState(() {
        // Update local state if needed, or just rely on parent rebuild
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final newUsername = _usernameController.text.trim();
      final oldUsername = widget.profile.username;

      // Check username availability if changed
      if (newUsername.isNotEmpty && newUsername != oldUsername) {
        setState(() => _isCheckingUsername = true);
        final isAvailable = await _usernameService.isUsernameAvailable(newUsername);
        setState(() => _isCheckingUsername = false);

        if (!isAvailable) {
          setState(() => _usernameError = 'Username is already taken');
          return;
        }
        
        // Reserve new username
        try {
          await _usernameService.reserveUsername(newUsername, widget.profile.uid);
          // Release old username if it existed
          if (oldUsername != null && oldUsername.isNotEmpty) {
            await _usernameService.releaseUsername(oldUsername);
          }
        } catch (e) {
          setState(() => _usernameError = 'Failed to reserve username');
          return;
        }
      }

      final updatedProfile = UserProfile(
        uid: widget.profile.uid,
        userType: widget.profile.userType,
        email: widget.profile.email,
        phoneNumber: _phoneController.text.trim(), // Save the phone number even if not verified yet? Or only if verified?
        // Let's save it, verification is separate status
        isVerified: widget.profile.isVerified, // This should ideally come from Firestore stream
        profilePictureUrl: widget.profile.profilePictureUrl,
        
        // Updated fields
        fullName: _fullNameController.text,
        username: newUsername.isEmpty ? null : newUsername,
        headline: _headlineController.text,
        education: _educationController.text,
        specializations: _specializations,
      );

      final collectionName = _getCollectionForUserType(widget.profile.userType);

      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(widget.profile.uid)
          .set(updatedProfile.toFirestore(), SetOptions(merge: true));

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  void _addSpecialization() {
    final spec = _specializationController.text.trim();
    if (spec.isNotEmpty && !_specializations.contains(spec)) {
      setState(() {
        _specializations.add(spec);
        _specializationController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: _isCheckingUsername 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save),
            onPressed: _isCheckingUsername ? null : _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixText: '@',
                  errorText: _usernameError,
                  helperText: 'Unique handle for identification',
                ),
                validator: _usernameService.validateUsername,
                onChanged: (_) {
                  if (_usernameError != null) setState(() => _usernameError = null);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '9876543210',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.profile.isVerified)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else
                    ElevatedButton(
                      onPressed: _isVerifyingPhone ? null : _verifyPhone,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: _isVerifyingPhone
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Verify'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _headlineController,
                decoration: const InputDecoration(labelText: 'Headline'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _educationController,
                decoration: const InputDecoration(labelText: 'Education'),
              ),
              const SizedBox(height: 24),
              _buildSpecializationsEditor(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecializationsEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Specializations', style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 8.0,
          children: _specializations.map((spec) {
            return Chip(
              label: Text(spec),
              onDeleted: () {
                setState(() {
                  _specializations.remove(spec);
                });
              },
            );
          }).toList(),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _specializationController,
                decoration: const InputDecoration(hintText: 'Add a specialization'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addSpecialization,
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _headlineController.dispose();
    _educationController.dispose();
    _specializationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

