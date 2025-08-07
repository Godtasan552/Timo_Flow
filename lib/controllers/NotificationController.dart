import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationController extends GetxController {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Reactive variables
  RxBool notificationsEnabled = true.obs;
  RxBool isInitialized = false.obs;
  RxString permissionStatus = 'unknown'.obs;

  // Constants
  static const String _notificationEnabledKey = 'notifications_enabled';
  static const String _taskChannelId = 'task_channel';
  static const String _taskChannelName = 'Task Notifications';
  static const String _taskChannelDescription = 'Notifications for upcoming tasks';

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await _initializeTimezone();
      await _configureNotificationSettings();
      await _requestPermissions();
      await _loadNotificationSetting();
      isInitialized.value = true;
      
      // Listen to notification enabled changes
      ever(notificationsEnabled, (enabled) {
        _saveNotificationSetting(enabled);
      });
      
    } catch (e) {
      print('Error initializing notifications: $e');
      isInitialized.value = false;
    }
  }

  Future<void> _initializeTimezone() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
  }

  Future<void> _configureNotificationSettings() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // ลบ onDidReceiveLocalNotification ออกเพราะ deprecated
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Handle notification tap - navigate to specific screen
      print('Notification tapped with payload: $payload');
      // You can use Get.toNamed() here to navigate
    }
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.notification.request();
    permissionStatus.value = status.toString();
    
    // For Android 13+, also request exact alarm permission if needed
    if (GetPlatform.isAndroid) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> _loadNotificationSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      notificationsEnabled.value = prefs.getBool(_notificationEnabledKey) ?? true;
    } catch (e) {
      print('Error loading notification setting: $e');
      notificationsEnabled.value = true;
    }
  }

  Future<void> _saveNotificationSetting(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationEnabledKey, enabled);
    } catch (e) {
      print('Error saving notification setting: $e');
    }
  }

  // Public method to toggle notifications
  void toggleNotifications() {
    notificationsEnabled.value = !notificationsEnabled.value;
  }

  Future<bool> scheduleTaskNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    String? sound,
  }) async {
    // Check if notifications are enabled
    if (!notificationsEnabled.value) {
      print('Notifications are disabled');
      return false;
    }

    // Check if controller is initialized
    if (!isInitialized.value) {
      print('NotificationController not initialized');
      return false;
    }

    // Validate scheduled time
    if (scheduledTime.isBefore(DateTime.now())) {
      print('Scheduled time is in the past');
      return false;
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        _taskChannelId,
        _taskChannelName,
        channelDescription: _taskChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        sound: sound != null ? RawResourceAndroidNotificationSound(sound) : null,
        enableVibration: true,
        enableLights: true,
        // แก้ไข ledColor ให้ใช้ Color.fromARGB หรือ Colors
        ledColor: const Color.fromARGB(255, 33, 150, 243),
        ledOnMs: 1000,
        ledOffMs: 500,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: sound,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);
      
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        notificationDetails,
        payload: payload,
        // แก้ไข parameter name
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // ลบ uiLocalNotificationDateInterpretation และ matchDateTimeComponents
        // เพราะเป็น deprecated parameters
      );

      print('Notification scheduled for: ${tzDateTime.toString()}');
      return true;
      
    } catch (e) {
      print('Error scheduling notification: $e');
      return false;
    }
  }

  // Schedule notification with reminder options
  Future<List<bool>> scheduleTaskWithReminders({
    required int baseId,
    required String title,
    required String body,
    required DateTime taskTime,
    List<Duration> reminders = const [
      Duration(minutes: 15),
      Duration(hours: 1),
      Duration(hours: 24),
    ],
  }) async {
    final results = <bool>[];
    
    for (int i = 0; i < reminders.length; i++) {
      final reminderTime = taskTime.subtract(reminders[i]);
      final notificationId = baseId + i + 1;
      
      String reminderTitle = title;
      String reminderBody = body;
      
      if (reminders[i].inDays > 0) {
        reminderTitle = '📅 Upcoming: $title';
        reminderBody = 'Reminder: Task due in ${reminders[i].inDays} day(s)';
      } else if (reminders[i].inHours > 0) {
        reminderTitle = '⏰ Reminder: $title';
        reminderBody = 'Task due in ${reminders[i].inHours} hour(s)';
      } else {
        reminderTitle = '🔔 Soon: $title';
        reminderBody = 'Task due in ${reminders[i].inMinutes} minute(s)';
      }
      
      final success = await scheduleTaskNotification(
        id: notificationId,
        title: reminderTitle,
        body: reminderBody,
        scheduledTime: reminderTime,
        payload: 'reminder_$baseId',
      );
      
      results.add(success);
    }
    
    return results;
  }

  Future<bool> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      print('Notification $id cancelled');
      return true;
    } catch (e) {
      print('Error cancelling notification $id: $e');
      return false;
    }
  }

  Future<bool> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      print('All notifications cancelled');
      return true;
    } catch (e) {
      print('Error cancelling all notifications: $e');
      return false;
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      print('Error getting pending notifications: $e');
      return [];
    }
  }

  // Check if notifications are allowed
  Future<bool> areNotificationsAllowed() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  // Request notification permissions if denied
  Future<bool> requestNotificationPermissions() async {
    if (await areNotificationsAllowed()) return true;
    
    final status = await Permission.notification.request();
    permissionStatus.value = status.toString();
    
    return status.isGranted;
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}