import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findom/models/user_profile_model.dart';

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

    final oldCollection = _getCollectionForUserType(widget.userProfile.userType);
    final newCollection = _getCollectionForUserType(_selectedType);
    final userDocRef = FirebaseFirestore.instance.collection(oldCollection).doc(widget.userProfile.uid);

    final updatedProfile = widget.userProfile.toFirestore()..['userType'] = _selectedType.toString();

    final batch = FirebaseFirestore.instance.batch();
    batch.delete(userDocRef); // Delete from the old collection
    batch.set(FirebaseFirestore.instance.collection(newCollection).doc(widget.userProfile.uid), updatedProfile); // Create in the new collection
    await batch.commit();

    if (mounted) {
      Navigator.of(context).pop();
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
