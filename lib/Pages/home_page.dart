import 'package:chatty_app/Components/user_tile.dart';
import 'package:chatty_app/Pages/chat_page.dart';
import 'package:chatty_app/services/auth/auth_service.dart';
import 'package:chatty_app/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import '../Components/my_drawer.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService(); // Use this instance

  // void logout() { // Original logout
  //   final auth = AuthService(); // Unnecessary new instance
  //   auth.signOut();
  // }

  // Corrected logout to use the existing _authService instance
  void logout() {
    _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ], // Added const for Icon
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading..");
        }
        // It's good practice to check if snapshot.data is null before using '!'
        if (snapshot.data == null) {
          return const Text(
            "No users found.",
          ); // Or some other appropriate widget
        }
        return ListView(
          children:
              snapshot.data!
                  .map<Widget>(
                    // Changed UserData to userData for convention
                    (userData) => _buildUserListItem(userData, context),
                  )
                  .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
    // Changed UserData to userData for convention
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    // Assuming the current user's email is available and not null
    final currentUserEmail = _authService.getCurentUser()?.email;

    // Ensure currentUserEmail is not null before comparison
    if (currentUserEmail != null && userData["email"] != currentUserEmail) {
      // Consistently use "email" (or whatever the correct key is)
      // Make sure the key "email" exists and is what you intend to display/pass
      final String userEmail =
          userData["email"] as String? ?? "No Email"; // Provide a fallback
      final String userID =
          userData["uid"] as String? ?? ""; // Provide a fallback

      return UserTile(
        text: userEmail, // Use the corrected key
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatPage(
                    receiverEmail: userEmail, // Use the corrected key
                    receiverID: userID, // Make sure "uid" is the correct key
                  ),
            ),
          );
        },
      );
    } else {
      return Container(); // Don't show the current user or if email is missing
    }
  }
}
