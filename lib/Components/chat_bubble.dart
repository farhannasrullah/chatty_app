import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final DateTime timestamp;
  final bool isDeleted;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.timestamp,
    this.isDeleted = false,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('h:mm a').format(timestamp);

    Color bubbleColor =
        isDeleted
            ? Colors.grey.shade400
            : isCurrentUser
            ? Colors.green
            : Colors.grey.shade500;

    Color textColor = isDeleted ? Colors.black54 : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft:
                isCurrentUser
                    ? const Radius.circular(12)
                    : const Radius.circular(0),
            bottomRight:
                isCurrentUser
                    ? const Radius.circular(0)
                    : const Radius.circular(12),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 18.0, right: 48),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isDeleted)
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Icon(
                        Icons.block, // atau Icons.remove_circle_outline
                        size: 16,
                        color: textColor,
                      ),
                    ),
                  Flexible(
                    child: Text(
                      isDeleted ? 'Pesan telah dihapus' : message,
                      style: TextStyle(
                        color: textColor,
                        fontStyle:
                            isDeleted ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: isCurrentUser ? 4 : null,
              left: isCurrentUser ? null : 4,
              child: Text(
                formattedTime,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
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
