import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final DateTime timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('h:mm a').format(timestamp);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.green : Colors.grey.shade500,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isCurrentUser ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight: isCurrentUser ? const Radius.circular(0) : const Radius.circular(12),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 18.0, right: 48), // space untuk waktu
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 0,
              right: isCurrentUser ? 4 : null,
              left: isCurrentUser ? null : 4,
              child: Text(
                formattedTime,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
