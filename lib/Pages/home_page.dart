import 'package:chatty_app/Components/user_tile.dart';
import 'package:chatty_app/Pages/chat_page.dart';
import 'package:chatty_app/services/auth/auth_service.dart';
import 'package:chatty_app/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import '../Components/my_drawer.dart';
import '../Pages/Login_Page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../Pages/Register_Page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import '../lifecycler_handler.dart'; // ✅ Pastikan file ini sesuai

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final user = FirebaseAuth.instance.currentUser!;
  late final LifecycleEventHandler _lifecycleEventHandler;

  void updateOnlineStatus(bool isOnline) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .update({
            'isOnline': isOnline,
            if (!isOnline) 'lastSeen': FieldValue.serverTimestamp(),
          });
    }
  }

  void logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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
      await _authService.setUserOnlineStatus(false);
      await _authService.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (context) => LoginPage(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RegisterPage(
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                    ),
                  );
                },
              ),
        ),
        (route) => false,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Berhasil logout")));
    }
  }

  @override
  void initState() {
    super.initState();

    // ✅ Tambahkan observer lifecycle
    _lifecycleEventHandler = LifecycleEventHandler(
      onResume: () async => updateOnlineStatus(true),
      onInactive: () async => updateOnlineStatus(false),
    );
    WidgetsBinding.instance.addObserver(_lifecycleEventHandler);

    // ✅ Set online saat masuk
    updateOnlineStatus(true);
  }

  @override
  void dispose() {
    // ✅ Hapus observer lifecycle
    WidgetsBinding.instance.removeObserver(_lifecycleEventHandler);
    super.dispose();
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

        final List<Map<String, dynamic>> users = snapshot.data!;
        users.sort((a, b) {
          Timestamp tsA =
              a['lastMessageTimestamp'] ??
              Timestamp.fromMillisecondsSinceEpoch(0);
          Timestamp tsB =
              b['lastMessageTimestamp'] ??
              Timestamp.fromMillisecondsSinceEpoch(0);
          return tsB.compareTo(tsA);
        });

        return ListView(
          children:
              users
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
    final currentUser = _authService.getCurentUser();
    if (currentUser == null || userData["email"] == currentUser.email)
      return null;

    final String displayName =
        userData["displayName"] ?? userData["email"] ?? "No Name";
    final String photoUrl = userData["photoURL"] ?? "";
    final String userID = userData["uid"] ?? "";
    final bool isOnline = userData["isOnline"] == true;

    return StreamBuilder<Map<String, dynamic>?>(
      stream: _chatService.getLastMessageBetween(currentUser.uid, userID),
      builder: (context, snapshot) {
        final lastMessageData = snapshot.data;
        final lastMessage = lastMessageData?['message'] ?? '';
        final lastSenderId = lastMessageData?['senderID'];
        final timestamp = lastMessageData?['timestamp'] as Timestamp?;

        String? formattedTime;
        if (timestamp != null) {
          final DateTime dateTime = timestamp.toDate();
          final now = DateTime.now();
          if (now.difference(dateTime).inDays == 0) {
            formattedTime = DateFormat('HH:mm').format(dateTime);
          } else {
            formattedTime = DateFormat('dd/MM').format(dateTime);
          }
        }

        return FutureBuilder<int>(
          future: getUnreadCount(userID),
          builder: (context, unreadSnapshot) {
            final unreadCount = unreadSnapshot.data ?? 0;

            return UserTile(
              text: displayName,
              subtitle: lastMessage,
              time: formattedTime,
              photoUrl: photoUrl,
              lastSenderId: lastSenderId,
              currentUserId: currentUser.uid,
              unreadCount: unreadCount,
              isOnline: isOnline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ChatPage(
                          receiverEmail: displayName,
                          receiverID: userID,
                        ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<int> getUnreadCount(String userId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot =
        await FirebaseFirestore.instance
            .collection('chat_rooms')
            .doc(ChatService().getChatRoomId(currentUserId, userId))
            .collection('messages')
            .where('receiverId', isEqualTo: currentUserId)
            .where('isRead', isEqualTo: false)
            .get();

    return snapshot.docs.length;
  }
}
