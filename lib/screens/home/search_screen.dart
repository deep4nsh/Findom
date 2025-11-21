import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findom/models/user_profile_model.dart';
import 'package:findom/screens/profile/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserProfile> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = <UserProfile>[];
      final collections = ['professionals', 'students', 'general_users'];

      // Firestore doesn't support OR queries across collections easily, so we query each independently
      // and combine results.
      for (final collection in collections) {
        final snapshot = await FirebaseFirestore.instance
            .collection(collection)
            .where('fullName', isGreaterThanOrEqualTo: query)
            .where('fullName', isLessThanOrEqualTo: '$query\uf8ff')
            .limit(10) // Limit per collection to avoid too many reads
            .get();

        for (final doc in snapshot.docs) {
          try {
            results.add(UserProfile.fromFirestore(doc));
          } catch (e) {
            // Skip malformed documents
            debugPrint('Error parsing user profile: $e');
          }
        }
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error searching users: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Users',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onSubmitted: _performSearch,
              textInputAction: TextInputAction.search,
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage.isNotEmpty)
            Expanded(child: Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))))
          else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
            const Expanded(child: Center(child: Text('No users found.')))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.profilePictureUrl != null
                          ? NetworkImage(user.profilePictureUrl!)
                          : null,
                      child: user.profilePictureUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(
                      user.fullName,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      user.userType.toString().split('.').last.toUpperCase(),
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(userId: user.uid),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
