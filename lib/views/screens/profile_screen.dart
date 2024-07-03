import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practice/services/user_auth_sevice.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _authService = UserAuthService();
  String username = '';
  File? _image;
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    if (_currentUser != null) {
      DocumentSnapshot user = await _authService.getUserInfo(_currentUser.uid);
      setState(() {
        username = user['userName'] ?? '';
        photoUrl = user['photoUrl'] ??
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSWwfGUCDwrZZK12xVpCOqngxSpn0BDpq6ewQ&s";
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      String? downloadUrl =
          await _authService.uploadProfileImage(_image!, _currentUser!.uid);
      if (downloadUrl != null) {
        setState(() {
          photoUrl = downloadUrl;
        });

        await _authService.updateProfile(_currentUser.uid, username,
            photoUrl: photoUrl);
      }
    }
  }

  Future<void> _editUsername() async {
    final TextEditingController _controller =
        TextEditingController(text: username);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Username'),
          content: TextField(
            onChanged: (value) {
              username = value;
            },
            controller: _controller,
            decoration: const InputDecoration(hintText: "Enter new username"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_controller.text.isNotEmpty) {
                  setState(() {
                    username = _controller.text;
                  });
                  await _authService.updateProfile(
                    _currentUser!.uid,
                    username,
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editUsername,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 120,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (photoUrl != null && photoUrl!.isNotEmpty
                          ? NetworkImage(photoUrl!)
                          : null),
                  child:
                      _image == null && (photoUrl == null || photoUrl!.isEmpty)
                          ? const Icon(Icons.add_a_photo,
                              size: 50, color: Colors.white)
                          : null,
                ),
              ),
              const Gap(20),
              Text(username),
            ],
          ),
        ),
      ),
    );
  }
}
