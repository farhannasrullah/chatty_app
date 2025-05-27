import 'package:chatty_app/Components/chat_bubble.dart';
import 'package:chatty_app/Components/my_textfield.dart';
import 'package:chatty_app/services/auth/auth_service.dart';
import 'package:chatty_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  // Changed to StatefulWidget
  final String receiverEmail;
  final String receiverID;

  const ChatPage({
    // Added const
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // State class
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController =
      ScrollController(); // For scrolling to bottom

  @override
  void initState() {
    super.initState();
    // Optionally, scroll to bottom when messages load or new ones arrive
    // This can be more complex depending on when you want the scroll to happen
  }

  @override
  void dispose() {
    _messageController.dispose(); // Dispose the controller
    _scrollController.dispose(); // Dispose scroll controller
    super.dispose();
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String messageText = _messageController.text;
      _messageController.clear(); // Clear before await to feel more responsive

      await _chatService.sendMessage(
        widget.receiverID,
        messageText,
      ); // Access receiverID via widget.

      // Scroll to bottom after sending
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    // Ensure the scroll controller is attached to a scroll view and has clients.
    if (_scrollController.hasClients) {
      // Wait for the next frame to ensure the new item is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail), // Access receiverEmail via widget.
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [Expanded(child: _buildMessageList()), _buildUserInput()],
      ),
    );
  }

  Widget _buildMessageList() {
    final String? senderID = _authService.getCurentUser()?.uid; // Nullable

    if (senderID == null) {
      // Handle case where user is not logged in or ID is not available
      return const Center(child: Text("Error: User not authenticated."));
    }

    return StreamBuilder<QuerySnapshot>(
      // Explicitly type StreamBuilder
      // Use the existing _chatService instance
      stream: _chatService.getMessages(
        widget.receiverID,
        senderID,
      ), // Access receiverID via widget.
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading messages."));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text("Loading.."));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No messages yet. Say hi!"));
        }

        // Scroll to bottom when new messages arrive and build is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });

        return ListView(
          controller: _scrollController, // Attach scroll controller
          padding: const EdgeInsets.all(8.0), // Add some padding
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    // It's safer to cast and check for null if doc.data() could be something else
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return const SizedBox.shrink(); // Or some error widget for a single message
    }

    final String? currentUserID = _authService.getCurentUser()?.uid;
    if (currentUserID == null) {
      // Should ideally not happen if checked in _buildMessageList
      return const SizedBox.shrink();
    }

    final bool isCurrentUser = data['senderID'] == currentUserID;
    final String message =
        data['message'] as String? ?? ''; // Handle potential null message

    // Ensure senderID in data is also a string if it might be otherwise
    // final String messageSenderID = data['senderID'] as String? ?? '';

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 8.0,
      ), // Add some margin
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [ChatBubble(message: message, isCurrentUser: isCurrentUser)],
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      // Adjust padding to be above the keyboard.
      // This might need more sophisticated handling with MediaQuery.of(context).viewInsets.bottom
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        left: 8,
        right: 8,
        top: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: MyTextfield(
              // Assuming MyTextfield is well-defined
              controller: _messageController,
              hintText: "Type a Message",
              obscureText: false,
            ),
          ),
          const SizedBox(width: 8), // Add some space
          Container(
            decoration: const BoxDecoration(
              color: Colors.green, // Or Theme.of(context).primaryColor
              shape: BoxShape.circle,
            ),
            // margin: const EdgeInsets.only(right: 25), // Margin handled by Padding and SizedBox
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
