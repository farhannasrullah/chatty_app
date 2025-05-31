import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? photoUrl;
  String? displayName;
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          photoUrl = data['photoUrl'];
          displayName = data['displayName'];
          _nameController.text = displayName ?? '';
        });
      }
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
      await uploadImage();
    }
  }

  Future<void> uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final storageRef = FirebaseStorage.instance.ref().child(
      'profile_images/$uid.jpg',
    );

    try {
      await storageRef.putFile(_selectedImage!);
      final url = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('Users').doc(uid).update({
        'photoUrl': url,
      });

      setState(() {
        photoUrl = url;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto profil berhasil diperbarui.")),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal upload foto: $e")));
    }
  }

  Future<void> saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final newName = _nameController.text.trim();

    if (uid != null && newName.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('Users').doc(uid).update({
          'displayName': newName,
        });

        setState(() {
          displayName = newName;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil disimpan.")),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal menyimpan profil: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider =
        _selectedImage != null
            ? FileImage(_selectedImage!)
            : (photoUrl != null && photoUrl!.isNotEmpty)
            ? NetworkImage(photoUrl!)
            : const AssetImage('assets/images/default_profile.jpg')
                as ImageProvider;

    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: imageProvider,
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: pickImage,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Nama Lengkap",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Masukkan nama lengkap Anda",
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: saveProfile,
                      icon: const Icon(Icons.save),
                      label: const Text("Simpan Profil"),
                    ),
                  ],
                ),
              ),
    );
  }
}
