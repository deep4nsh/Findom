import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findom/models/user_profile_model.dart';
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
  List<String> _specializations = [];
  
  bool _isCheckingUsername = false;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _usernameController = TextEditingController(text: widget.profile.username);
    _headlineController = TextEditingController(text: widget.profile.headline);
    _educationController = TextEditingController(text: widget.profile.education);
    _specializationController = TextEditingController();
    _specializations = List<String>.from(widget.profile.specializations);
  }
  
  String _getCollectionForUserType(UserType userType) {
    switch (userType) {
      case UserType.professional:
        return 'professionals';
      case UserType.student:
        return 'students';
      case UserType.company:
        return 'companies';
      case UserType.general:
        return 'general_users';
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
        phoneNumber: widget.profile.phoneNumber,
        isVerified: widget.profile.isVerified,
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
    super.dispose();
  }
}

