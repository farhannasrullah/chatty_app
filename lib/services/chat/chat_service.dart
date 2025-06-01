import 'package:chatty_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String getChatRoomId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return sortedIds.join('_');
  }

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        if (!user.containsKey("lastMessageTimestamp")) {
          user["lastMessageTimestamp"] = Timestamp.fromMillisecondsSinceEpoch(
            0,
          );
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
      lastMessage: message,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');
    await _firestore.collection("chat_rooms").doc(chatRoomID).set({
      'lastMessage': message,
      'lastMessageTimestamp': timestamp,
      'lastSenderID': currentUserID, // ✅ Tambahkan ini
      'participants': [currentUserID, receiverID],
    }, SetOptions(merge: true));

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

  Future<String?> getLastMessage(String chatId) async {
    final snapshot =
        await _firestore
            .collection('chat_rooms')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['message'];
    } else {
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> getChatRooms() {
    final String currentUserID = _auth.currentUser!.uid;

    return _firestore
        .collection("chat_rooms")
        .where("participants", arrayContains: currentUserID)
        .orderBy("lastMessageTimestamp", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['chatRoomID'] = doc.id;
            return data;
          }).toList();
        });
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

  Stream<Map<String, dynamic>?> getLastMessageBetween(
    String userId1,
    String userId2,
  ) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final doc = snapshot.docs.first;
            return {
              'message': doc['message'],
              'timestamp': doc['timestamp'],
              'senderID': doc['senderID'],
            };
          } else {
            return null;
          }
        });
  }
}
