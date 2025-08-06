import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../components/drawer.dart';
import '../controllers/auth_controller.dart';
import '../services/universal_storage_service.dart';
import '../model/user_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthController authController = Get.find();
  bool _notificationsEnabled = true;

  Future<void> _changeUsername() async {
    final newName = await _showInputDialog(
      'Change Username',
      authController.currentUser.value?.username ?? '',
    );
    if (newName != null && newName.isNotEmpty) {
      final users = await StorageService.loadUsers();
      final index = users.indexWhere(
        (u) => u.id == authController.currentUser.value!.id,
      );
      if (index != -1) {
        users[index] = User(
          id: users[index].id,
          email: users[index].email,
          username: newName,
          password: users[index].password,
          profileImage: users[index].profileImage,
        );
        await StorageService.saveUsers(users);
        authController.currentUser.value = users[index];
        setState(() {});
      }
    }
  }

  Future<void> _changePassword() async {
    final newPassword = await _showInputDialog('Change Password', '');
    if (newPassword != null && newPassword.isNotEmpty) {
      final users = await StorageService.loadUsers();
      final index = users.indexWhere(
        (u) => u.id == authController.currentUser.value!.id,
      );
      if (index != -1) {
        users[index] = User(
          id: users[index].id,
          email: users[index].email,
          username: users[index].username,
          password: newPassword,
          profileImage: users[index].profileImage,
        );
        await StorageService.saveUsers(users);
        authController.currentUser.value = users[index];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password changed successfully")),
        );
      }
    }
  }

  Future<void> _changeProfilePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final imagePath = picked.path;
      final users = await StorageService.loadUsers();
      final index = users.indexWhere(
        (u) => u.id == authController.currentUser.value!.id,
      );
      if (index != -1) {
        users[index] = User(
          id: users[index].id,
          email: users[index].email,
          username: users[index].username,
          password: users[index].password,
          profileImage: imagePath,
        );
        await StorageService.saveUsers(users);
        authController.currentUser.value = users[index];
        setState(() {});
      }
    }
  }

  Future<String?> _showInputDialog(String title, String initialValue) async {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: title.toLowerCase().contains("password"),
          decoration: const InputDecoration(hintText: "Enter new value"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser.value;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          backgroundColor: Colors.pinkAccent,
        ),
        drawer: const MyDrawer(),
        body: const Center(child: Text("No user logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.pinkAccent,
      ),
      drawer: const MyDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5DDFF), Color(0xFFFFBDBD), Color(0xFFFFE1E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile picture with edit button
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.pinkAccent,
                            backgroundImage: user.profileImage != null
                                ? FileImage(File(user.profileImage!))
                                : null,
                            child: user.profileImage == null
                                ? const Icon(Icons.person,
                                    size: 40, color: Colors.white)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _changeProfilePicture,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.pink, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.username,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            "Online",
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Change username option
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Change Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Change your username'),
                    onTap: _changeUsername,
                  ),

                  // Change password option
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Change Password',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Change your password'),
                    onTap: _changePassword,
                  ),

                  // Notification toggle option
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Notifications',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Enable or disable notifications'),
                    trailing: Switch(
                      value: _notificationsEnabled,
                      activeColor: Colors.orange,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _notificationsEnabled = !_notificationsEnabled;
                      });
                    },
                  ),

                  const SizedBox(height: 8),

                  // Logout option
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Logout your account',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      authController.logout();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
