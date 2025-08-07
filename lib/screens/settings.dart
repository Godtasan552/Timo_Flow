import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../components/drawer.dart';
import '../controllers/auth_controller.dart';
import '../controllers/NotificationController.dart';  // Import NotificationController แยก
import '../services/universal_storage_service.dart';
import '../model/user_model.dart';

// Settings Page
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthController authController = Get.find();
  late NotificationController notificationController;

  @override
  void initState() {
    super.initState();
    // Initialize notification controller if not already done
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController());
    }
    notificationController = Get.find<NotificationController>();
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username changed successfully")),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture changed successfully")),
        );
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

  Future<void> _testNotification() async {
    final success = await notificationController.scheduleTaskNotification(
      id: 999,
      title: 'Test Notification',
      body: 'This is a test notification from your app!',
      scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
      payload: 'test_notification',
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Test notification scheduled in 5 seconds")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to schedule test notification")),
      );
    }
  }

  Future<void> _showNotificationInfo() async {
    final pending = await notificationController.getPendingNotifications();
    final isAllowed = await notificationController.areNotificationsAllowed();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Permission Status: ${isAllowed ? "Granted" : "Denied"}'),
            Text('Pending Notifications: ${pending.length}'),
            Text('Controller Status: ${notificationController.isInitialized.value ? "Initialized" : "Not Initialized"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
                  // Profile Section
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

                  // Account Settings Section
                  const Divider(),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Account Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Change username option
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person_outline, color: Colors.pink),
                    title: const Text(
                      'Change Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Current: ${user.username}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _changeUsername,
                  ),

                  // Change password option
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_outline, color: Colors.pink),
                    title: const Text(
                      'Change Password',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Update your password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _changePassword,
                  ),

                  // Notification Settings Section
                  const Divider(),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Notification Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Notification toggle option with Obx
                  Obx(() => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications_outlined, color: Colors.pink),
                    title: const Text(
                      'Enable Notifications',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(notificationController.notificationsEnabled.value 
                        ? 'Notifications are enabled' 
                        : 'Notifications are disabled'),
                    trailing: Switch(
                      value: notificationController.notificationsEnabled.value,
                      activeColor: Colors.orange,
                      onChanged: (value) async {
                        if (value) {
                          final hasPermission = await notificationController.requestNotificationPermissions();
                          if (hasPermission) {
                            await notificationController.saveNotificationSetting(value);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Notification permission denied")),
                            );
                          }
                        } else {
                          await notificationController.saveNotificationSetting(value);
                        }
                      },
                    ),
                    onTap: () async {
                      final currentValue = notificationController.notificationsEnabled.value;
                      if (!currentValue) {
                        final hasPermission = await notificationController.requestNotificationPermissions();
                        if (hasPermission) {
                          await notificationController.saveNotificationSetting(!currentValue);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Notification permission denied")),
                          );
                        }
                      } else {
                        await notificationController.saveNotificationSetting(!currentValue);
                      }
                    },
                  )),

                  // Test notification option
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications_active, color: Colors.orange),
                    title: const Text(
                      'Test Notification',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Send a test notification'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _testNotification,
                  ),

                  // Notification info option
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline, color: Colors.blue),
                    title: const Text(
                      'Notification Info',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('View notification status'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showNotificationInfo,
                  ),

                  // Clear all notifications
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.clear_all, color: Colors.grey),
                    title: const Text(
                      'Clear All Notifications',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Cancel all pending notifications'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final success = await notificationController.cancelAllNotifications();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success 
                            ? "All notifications cleared" 
                            : "Failed to clear notifications")),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  const Divider(),

                  // Logout option
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Sign out from your account',
                      style: TextStyle(color: Colors.red),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.red),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                authController.logout();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
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