import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/models/user_model.dart';
import 'package:findom/models/profile_model.dart';
import 'package:findom/screens/profile/edit_profile_screen.dart';
import 'package:findom/services/locator.dart';
import 'package:findom/services/network_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final NetworkService _networkService = locator<NetworkService>();
  late Future<Map<String, dynamic>> _profileData;

  @override
  void initState() {
    super.initState();
    _profileData = _fetchProfileData();
  }

  // Corrected: Removed self-healing logic. Responsibility is now with AuthWrapper.
  Future<Map<String, dynamic>> _fetchProfileData() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    final profileDoc = await FirebaseFirestore.instance.collection('profiles').doc(widget.userId).get();

    if (!userDoc.exists || !profileDoc.exists) {
      // The FutureBuilder will catch this and display a user-friendly error.
      throw Exception('User data or profile data not found. The account may be incomplete or have been created before the full onboarding process.');
    }

    return {
      'user': AppUser.fromFirestore(userDoc),
      'profile': Profile.fromFirestore(profileDoc),
    };
  }

  void _refreshProfileData() {
    setState(() {
      _profileData = _fetchProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            appBar: null,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: Text('An error occurred while loading the profile: \n${snapshot.error}')),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(child: Text('Profile data could not be loaded.')),
          );
        }

        final AppUser user = snapshot.data!['user'];
        final Profile profile = snapshot.data!['profile'];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              if (widget.userId == FirebaseAuth.instance.currentUser?.uid)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(profile: profile),
                      ),
                    );
                    _refreshProfileData();
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, user, profile),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildSectionTitle('Headline'),
                Text(profile.headline.isNotEmpty ? profile.headline : 'No headline provided.'),
                const Divider(height: 32),
                _buildSectionTitle('Specializations'),
                profile.specializations.isNotEmpty
                    ? Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: profile.specializations
                            .map((spec) => Chip(label: Text(spec)))
                            .toList(),
                      )
                    : const Text('No specializations listed.'),
                const Divider(height: 32),
                _buildSectionTitle('Education'),
                Text(profile.education.isNotEmpty ? profile.education : 'No education listed.'),
              ],
            ),
          ),
        );
      },
    );
  }

   Widget _buildHeader(BuildContext context, AppUser user, Profile profile) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: profile.profilePictureUrl != null
              ? NetworkImage(profile.profilePictureUrl!)
              : null,
          child: profile.profilePictureUrl == null
              ? const Icon(Icons.person, size: 40)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      profile.fullName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (user.isVerified)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.verified, color: Colors.blue, size: 20),
                    ),
                ],
              ),
              Text(user.userType.toString().split('.').last.toUpperCase()),
              if (widget.userId != FirebaseAuth.instance.currentUser?.uid)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildFollowButton(),
                )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFollowButton() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('followers')
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final bool isFollowing = snapshot.data!.exists;

        return ElevatedButton(
          onPressed: () async {
            if (isFollowing) {
              await _networkService.unfollowUser(widget.userId);
            } else {
              await _networkService.followUser(widget.userId);
            }
          },
          child: Text(isFollowing ? 'Unfollow' : 'Follow'),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStat('Followers', widget.userId, 'followers'),
        _buildStat('Following', widget.userId, 'following'),
      ],
    );
  }

  Widget _buildStat(String label, String userId, String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).collection(collection).snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Column(
          children: [
            Text(count.toString(), style: Theme.of(context).textTheme.titleLarge),
            Text(label),
          ],
        );
      },
    );
  }
}
