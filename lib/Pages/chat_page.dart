import 'package:chatty_app/Components/chat_bubble.dart'; // Sesuaikan path jika perlu
import 'package:chatty_app/Components/my_textfield.dart'; // Sesuaikan path jika perlu
import 'package:chatty_app/services/auth/auth_service.dart'; // Sesuaikan path jika perlu
import 'package:chatty_app/services/chat/chat_service.dart'; // Sesuaikan path jika perlu
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot>? _messageStream;

  @override
  void initState() {
    super.initState();
    final currentUser = _authService.getCurentUser();
    if (currentUser != null) {
      _messageStream = _chatService.getMessages(
        widget.receiverID,
        currentUser.uid,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String messageText = _messageController.text;
      _messageController.clear();

      try {
        await _chatService.sendMessage(widget.receiverID, messageText);
        _scrollToBottom();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal mengirim pesan: $e")));
      }
    }
  }

  void markMessagesAsRead(String chatRoomID, String senderID) async {
    final unreadMessages =
        await _firestore
            .collection("chat_rooms")
            .doc(chatRoomID)
            .collection("messages")
            .where("senderID", isEqualTo: senderID)
            .where("isRead", isEqualTo: false)
            .get();

    for (var doc in unreadMessages.docs) {
      await doc.reference.update({"isRead": true});
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // Fungsi bantu: cek apakah dua tanggal sama hari
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Fungsi bantu format label tanggal seperti WA
  String _getFormattedDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return "Today";
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return "Yesterday";
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat.EEEE().format(date); // nama hari, misal Friday
    } else if (now.year == date.year) {
      return DateFormat.MMMd().format(date); // Apr 21
    } else {
      return DateFormat.yMMMd().format(date); // Apr 21, 2023
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        title: StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('Users')
                  .doc(widget.receiverID)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text(widget.receiverEmail);
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final isOnline = userData['isOnline'] ?? false;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverEmail,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            );
          },
        ),
      ),

      // ✅ Tambahkan ini
      body: _buildMessageList(),
      bottomNavigationBar: _buildUserInput(),
    );
  }

  Widget _buildMessageList() {
    if (_messageStream == null) {
      return const Center(
        child: Text(
          "Tidak dapat memuat pesan. Pengguna tidak terautentikasi atau stream error.",
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _messageStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text("Memuat pesan..."));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("Belum ada pesan. Ayo mulai percakapan!"),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          reverse: false,
          padding: const EdgeInsets.all(8.0),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>?;

            if (data == null || data['timestamp'] == null) {
              return const SizedBox.shrink();
            }

            final timestamp = (data['timestamp'] as Timestamp).toDate();

            bool showDateHeader = false;

            if (index == 0) {
              showDateHeader = true;
            } else {
              final prevDoc = snapshot.data!.docs[index - 1];
              final prevData = prevDoc.data() as Map<String, dynamic>?;
              if (prevData != null && prevData['timestamp'] != null) {
                final prevTimestamp =
                    (prevData['timestamp'] as Timestamp).toDate();
                if (!isSameDay(prevTimestamp, timestamp)) {
                  showDateHeader = true;
                }
              }
            }

            List<Widget> widgets = [];

            if (showDateHeader) {
              widgets.add(
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getFormattedDateLabel(timestamp),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }

            widgets.add(_buildMessageItem(doc));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widgets,
            );
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

    if (data == null) {
      return const SizedBox.shrink();
    }

    final currentUser = _authService.getCurentUser();
    if (currentUser == null) {
      return ChatBubble(
        message: data['message'] as String? ?? "[Pesan tidak valid]",
        isCurrentUser: false,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );
    }

    bool isCurrentUser = (data['senderID'] == currentUser.uid);

    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ChatBubble(
        message: data['message'] as String? ?? "[Pesan Kosong]",
        isCurrentUser: isCurrentUser,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 8.0,
        left: 8.0,
        right: 8.0,
        top: 8.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: MyTextfield(
              controller: _messageController,
              hintText: "Ketik pesan...",
              obscureText: false,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
