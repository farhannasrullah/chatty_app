import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurentUser() {
    return _auth.currentUser;
  }

  // LOGIN
  Future<UserCredential> signInwithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Ambil data user dari Firestore
      final doc = await _firestore.collection("Users").doc(uid).get();
      final data = doc.data();

      if (data != null) {
        final name = data['displayName'] ?? '';
        final photoURL = data['photoURL'] ?? '';

        // Sync ke FirebaseAuth profile
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.updatePhotoURL(photoURL);
      }

      // OPTIONAL: Tambahkan email jika belum ada (jaga-jaga)
      await _firestore.collection("Users").doc(uid).set({
        'uid': uid,
        'email': email,
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // REGISTER
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
    String name, {
    String? photoURL,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'displayName': name,
        'photoURL': photoURL ?? '',
      });

      // Update FirebaseAuth profile
      await userCredential.user!.updateDisplayName(name);
      if (photoURL != null) {
        await userCredential.user!.updatePhotoURL(photoURL);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
