import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/models/job_model.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  EmploymentType _employmentType = EmploymentType.fullTime;
  bool _isSubmitting = false;

  Future<void> _submitJob() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return; // Should not happen if they are on this screen

      final newJob = Job(
        id: ' ', // Firestore will generate
        companyId: user.uid, // The company is the current user
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        employmentType: _employmentType,
        postedDate: Timestamp.now(),
      );

      await FirebaseFirestore.instance.collection('jobs').add(newJob.toFirestore());

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a New Job'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSubmitting ? null : _submitJob,
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
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Job Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location (e.g., Mumbai, Remote)'),
                validator: (value) => value!.isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EmploymentType>(
                value: _employmentType,
                decoration: const InputDecoration(labelText: 'Employment Type'),
                items: EmploymentType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.toString().split('.').last));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _employmentType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Job Description'),
                maxLines: 8,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              if (_isSubmitting) const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: LinearProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
