import 'package:chatty_app/models/message.dart'; // Pastikan path model Message benar
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Future<void> sendMessage(String receiverID, message) async {
    // Pastikan currentUser tidak null sebelum mengakses propertinya
    if (_auth.currentUser == null) {
      print("Error: Current user is null in sendMessage.");
      throw Exception("User not logged in"); // atau handle error lain
    }
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail =
        _auth.currentUser!.email ?? ""; // Beri fallback jika email null

    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_'); // Tetap menggunakan underscore (_)

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    // Nama parameter diubah agar lebih jelas
    List<String> ids = [userID, otherUserID];
    ids.sort();
    // SAMAKAN DENGAN YANG DI sendMessage
    String chatRoomID = ids.join(
      '_',
    ); // <-- PERBAIKAN DI SINI: ubah '-' menjadi '_'

    print(
      "ChatService: Mendengarkan pesan dari chatRoomID: $chatRoomID",
    ); // Tambahkan log ini

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
