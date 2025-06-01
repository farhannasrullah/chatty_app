import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text; // Nama pengguna
  final String? subtitle; // Pesan terakhir
  final String? time; // Waktu pesan terakhir
  final String? photoUrl; // URL foto profil
  final String? lastSenderId; // ID pengirim pesan terakhir
  final String? currentUserId; // ID pengguna saat ini
  final int unreadCount;
  final void Function()? onTap;
  final bool isOnline; // ✅ Tambahkan flag online

  const UserTile({
    super.key,
    required this.text,
    this.subtitle,
    this.time,
    this.photoUrl,
    this.lastSenderId,
    this.unreadCount = 0,
    this.currentUserId,
    this.onTap,
    required this.isOnline, // ✅ Wajib diisi
  });

  @override
  Widget build(BuildContext context) {
    String prefix = '';
    if (lastSenderId != null && currentUserId != null) {
      prefix = lastSenderId == currentUserId ? 'You: ' : '';
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage:
                (photoUrl != null && photoUrl!.isNotEmpty)
                    ? NetworkImage(photoUrl!)
                    : null,
            child:
                (photoUrl == null || photoUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 30)
                    : null,
          ),
          if (isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        subtitle != null && subtitle!.isNotEmpty
            ? '$prefix$subtitle'
            : 'Tidak ada pesan terakhir',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: subtitle == null || subtitle!.isEmpty ? Colors.grey : null,
          fontStyle:
              subtitle == null || subtitle!.isEmpty ? FontStyle.italic : null,
        ),
      ),
      trailing:
          time != null
              ? Text(
                time!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
              : null,
    );
  }
}
