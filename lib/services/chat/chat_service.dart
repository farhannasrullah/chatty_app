import 'package:chatty_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        if (!user.containsKey("lastMessageTimestamp")) {
          user["lastMessageTimestamp"] = Timestamp.fromMillisecondsSinceEpoch(0);
        }
        return user;
      }).toList();
    });
  }

  Future<void> sendMessage(String receiverID, message) async {
    if (_auth.currentUser == null) {
      print("Error: Current user is null in sendMessage.");
      throw Exception("User not logged in");
    }
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email ?? "";

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
    String chatRoomID = ids.join('_');

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());

    // Update lastMessageTimestamp di kedua user
    await Future.wait([
      _firestore.collection("Users").doc(currentUserID).update({
        "lastMessageTimestamp": timestamp,
      }),
      _firestore.collection("Users").doc(receiverID).update({
        "lastMessageTimestamp": timestamp,
      }),
    ]);
  }

  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    print("ChatService: Mendengarkan pesan dari chatRoomID: $chatRoomID");

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
