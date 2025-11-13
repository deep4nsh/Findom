import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:findom/models/user_profile_model.dart';
import 'package:findom/services/user_profile_provider.dart';

class RoleSelectionScreen extends StatefulWidget {
  final UserProfile userProfile;

  const RoleSelectionScreen({super.key, required this.userProfile});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserType _selectedType;

  _RoleSelectionScreenState() : _selectedType = UserType.general; // Default selection

  @override
  void initState() {
    super.initState();
    _selectedType = widget.userProfile.userType;
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

  Future<void> _updateUserRole() async {
    if (widget.userProfile.userType == _selectedType) {
      // No change, just pop the screen
      Navigator.of(context).pop();
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final oldCollection = _getCollectionForUserType(widget.userProfile.userType);
      final newCollection = _getCollectionForUserType(_selectedType);
      
      debugPrint('Changing role from ${widget.userProfile.userType} to $_selectedType');
      debugPrint('Moving from $oldCollection to $newCollection');

      // Create the updated profile data
      final updatedProfile = widget.userProfile.toFirestore();
      updatedProfile['userType'] = _selectedType.toString();

      // Use batch to ensure atomic operation
      final batch = FirebaseFirestore.instance.batch();
      
      // Delete from old collection
      final oldDocRef = FirebaseFirestore.instance.collection(oldCollection).doc(widget.userProfile.uid);
      batch.delete(oldDocRef);
      
      // Create in new collection
      final newDocRef = FirebaseFirestore.instance.collection(newCollection).doc(widget.userProfile.uid);
      batch.set(newDocRef, updatedProfile);
      
      // Commit the batch
      await batch.commit();
      
      debugPrint('Role updated successfully');

      // Make sure global user profile updates immediately across the app
      if (mounted) {
        await context.read<UserProfileProvider>().reload();
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.of(context).pop(true); // Return to profile with success flag
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role updated successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error updating role: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update role: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Your Role'),
        actions: [
          TextButton(
            onPressed: _updateUserRole,
            child: const Text('Save'),
          )
        ],
      ),
      body: ListView(
        children: UserType.values.map((type) {
          return ListTile(
            title: Text(type.toString().split('.').last.toUpperCase()),
            // ignore: deprecated_member_use
            leading: Radio<UserType>(
              value: type,
              // ignore: deprecated_member_use
              groupValue: _selectedType,
              // ignore: deprecated_member_use
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            onTap: () {
              setState(() {
                _selectedType = type;
              });
            },
          );
        }).toList(),
      ),
    );
  }
}
