import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/models/user_profile_model.dart';
import 'package:findom/screens/profile/edit_profile_screen.dart';
import 'package:findom/screens/profile/role_selection_screen.dart';
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
  late Future<UserProfile> _profileData;

  @override
  void initState() {
    super.initState();
    _profileData = _fetchProfileData();
  }

  Future<UserProfile> _fetchProfileData() async {
    final doc = await _getUserDocument(widget.userId);
    if (doc == null) {
      throw Exception('This user\'s profile could not be found in any collection.');
    }
    return UserProfile.fromFirestore(doc);
  }

  Future<DocumentSnapshot?> _getUserDocument(String uid) async {
    final collections = ['professionals', 'students', 'general_users', 'companies'];
    for (final collection in collections) {
      final doc = await FirebaseFirestore.instance.collection(collection).doc(uid).get();
      if (doc.exists) {
        return doc;
      }
    }
    return null;
  }


  void _refreshProfileData() {
    setState(() {
      _profileData = _fetchProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: _profileData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(appBar: null, body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: Text('An error occurred: ${snapshot.error}')),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(child: Text('Profile data could not be loaded.')),
          );
        }

        final userProfile = snapshot.data!;
        final isCurrentUser = widget.userId == FirebaseAuth.instance.currentUser?.uid;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              if (isCurrentUser)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                     await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(profile: userProfile),
                      ),
                    );
                    _refreshProfileData();
                  },
                ),
              if (isCurrentUser)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') {
                      FirebaseAuth.instance.signOut();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, userProfile),
                const SizedBox(height: 24),
                _buildStatsRow(), 
                const SizedBox(height: 24),
                 if (isCurrentUser)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => RoleSelectionScreen(userProfile: userProfile),
                        ));
                        _refreshProfileData();
                      },
                      child: const Text('Change Role'),
                    ),
                  ),
                const SizedBox(height: 16),
                _buildSectionTitle('Headline'),
                Text(userProfile.headline.isNotEmpty ? userProfile.headline : 'No headline provided.'),
                const Divider(height: 32),
                _buildSectionTitle('Specializations'),
                userProfile.specializations.isNotEmpty
                    ? Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: userProfile.specializations
                            .map((spec) => Chip(label: Text(spec)))
                            .toList(),
                      )
                    : const Text('No specializations listed.'),
                const Divider(height: 32),
                _buildSectionTitle('Education'),
                Text(userProfile.education.isNotEmpty ? userProfile.education : 'No education listed.'),
              ],
            ),
          ),
        );
      },
    );
  }

   Widget _buildHeader(BuildContext context, UserProfile userProfile) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: userProfile.profilePictureUrl != null
              ? NetworkImage(userProfile.profilePictureUrl!)
              : null,
          child: userProfile.profilePictureUrl == null
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
                      userProfile.fullName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (userProfile.isVerified)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.verified, color: Colors.blue, size: 20),
                    ),
                ],
              ),
              Text(userProfile.userType.toString().split('.').last.toUpperCase()),
              if (FirebaseAuth.instance.currentUser?.uid != null && widget.userId.trim() != FirebaseAuth.instance.currentUser!.uid.trim())
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
          .collection('followers')
          .doc(widget.userId)
          .collection('userFollowers')
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
        _buildStat('Followers', 'followers', 'userFollowers', widget.userId),
        _buildStat('Following', 'following', 'userFollowing', widget.userId),
      ],
    );
  }

  Widget _buildStat(String label, String topLevelCollection, String subCollection, String docId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(topLevelCollection).doc(docId).collection(subCollection).snapshots(),
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
