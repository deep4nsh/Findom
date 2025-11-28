import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/models/post_model.dart';
import 'package:findom/services/locator.dart';
import 'package:findom/services/image_upload_service.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final ImageUploadService _imageUploadService = locator<ImageUploadService>();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool _isSubmitting = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(source: source);
    setState(() {
      _imageFile = selectedImage;
    });
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be signed in to post.')),
          );
        }
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _imageUploadService.uploadImage(File(_imageFile!.path));
      }

      final newPost = Post(
        id: ' ', // Firestore will generate
        authorId: user.uid,
        content: _contentController.text,
        imageUrl: imageUrl,
        timestamp: Timestamp.now(),
        likes: const [],
      );

      await FirebaseFirestore.instance.collection('posts').add(newPost.toFirestore());

      if (mounted) {
        // Keep the create post UI visible like LinkedIn: clear and reset instead of closing
        setState(() {
          _isSubmitting = false;
          _contentController.clear();
          _imageFile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isSubmitting ? null : _submitPost,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'What\'s on your mind?',
                  border: InputBorder.none,
                ),
                maxLines: null,
                validator: (value) =>
                    value!.trim().isEmpty ? 'Post content cannot be empty' : null,
              ),
              const SizedBox(height: 16),
              if (_imageFile != null)
                Image.file(File(_imageFile!.path), height: 200),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
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
    _contentController.dispose();
    super.dispose();
  }
}
