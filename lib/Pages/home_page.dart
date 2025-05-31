import 'package:chatty_app/Components/user_tile.dart';
import 'package:chatty_app/Pages/chat_page.dart';
import 'package:chatty_app/services/auth/auth_service.dart';
import 'package:chatty_app/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import '../Components/my_drawer.dart';
import '../Pages/Login_Page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  void logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah kamu yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _authService.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(onTap: () {})),
        (route) => false,
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Berhasil logout")));
    }
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
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error memuat daftar pengguna"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Tidak ada pengguna ditemukan"));
        }

        // Sort user berdasarkan lastMessageTimestamp descending
        final List<Map<String, dynamic>> users = snapshot.data!;
        users.sort((a, b) {
          Timestamp tsA = a['lastMessageTimestamp'] ?? Timestamp.fromMillisecondsSinceEpoch(0);
          Timestamp tsB = b['lastMessageTimestamp'] ?? Timestamp.fromMillisecondsSinceEpoch(0);
          return tsB.compareTo(tsA);
        });

        return ListView(
          children: users
              .map((userData) => _buildUserListItem(userData, context))
              .where((widget) => widget != null)
              .cast<Widget>()
              .toList(),
        );
      },
    );
  }

  Widget? _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    final currentUserEmail = _authService.getCurentUser()?.email;

    if (currentUserEmail != null && userData["email"] != currentUserEmail) {
      final String userEmail = userData["email"] as String? ?? "No Email";
      final String userID = userData["uid"] as String? ?? "";

      return UserTile(
        text: userEmail,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userEmail,
                receiverID: userID,
              ),
            ),
          );
        },
      );
    } else {
      return null; // Jangan tampilkan user yang sama dengan current user
    }
  }
}
