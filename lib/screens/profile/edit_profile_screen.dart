import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findom/models/profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  final Profile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _headlineController;
  late TextEditingController _educationController;
  late TextEditingController _specializationController;
  List<String> _specializations = [];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _headlineController = TextEditingController(text: widget.profile.headline);
    _educationController = TextEditingController(text: widget.profile.education);
    _specializationController = TextEditingController();
    _specializations = List<String>.from(widget.profile.specializations);
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = Profile(
        uid: widget.profile.uid,
        fullName: _fullNameController.text,
        headline: _headlineController.text,
        education: _educationController.text,
        specializations: _specializations,
        profilePictureUrl: widget.profile.profilePictureUrl, // Not handling image upload yet
      );

      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(widget.profile.uid)
          .update(updatedProfile.toFirestore());

      if (mounted) {
        Navigator.of(context).pop();
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
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
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
    _headlineController.dispose();
    _educationController.dispose();
    _specializationController.dispose();
    super.dispose();
  }
}
