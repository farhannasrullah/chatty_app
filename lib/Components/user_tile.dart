import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final String? time; // Waktu terakhir chat
  final void Function()? onTap;

  const UserTile({
    super.key,
    required this.text,
    required this.onTap,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 20),
                Text(text),
              ],
            ),
            if (time != null)
              Text(
                time!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
