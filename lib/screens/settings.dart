import 'package:flutter/material.dart';
import '../components/drawer.dart'; // ถ้ามี Drawer ของคุณเอง

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Column(
          children: [
            const SizedBox(
              height: 120,
            ), // เพิ่มระยะห่างให้ Card ลงมาด้านล่างมากขึ้น
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75, // 👈 ความสูง 75% ของหน้าจอ
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
                        // Icon user + ชื่อ
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Benny',
                                      style: TextStyle(
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
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Change name
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'change name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('change your user name'),
                          onTap: () {
                            // TODO: เพิ่ม action สำหรับเปลี่ยนชื่อ
                            print('Change name tapped');
                          },
                        ),

                        // Change password
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'change password',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('change your password'),
                          onTap: () {
                            // TODO: เพิ่ม action สำหรับเปลี่ยนรหัสผ่าน
                            print('Change password tapped');
                          },
                        ),

                        // Notification toggle
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'notification',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('turn on, turn off notification'),
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
                            // Toggle notification เมื่อกดที่ ListTile
                            setState(() {
                              _notificationsEnabled = !_notificationsEnabled;
                            });
                          },
                        ),

                        const SizedBox(height: 8),

                        // Logout
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
                            'logout your account',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () {
                            // TODO: เพิ่ม action สำหรับ logout
                            print('Logout tapped');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ),),
          ],
        ),
      ),
    );
  }
}
