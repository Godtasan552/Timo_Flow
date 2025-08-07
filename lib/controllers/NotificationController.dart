import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'dart:io';

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
      
      print('NotificationController initialized successfully');
    } catch (e) {
      print('Error initializing notifications: $e');
      isInitialized.value = false;
    }
  }

  Future<void> _initializeTimezone() async {
    try {
      tz_data.initializeTimeZones();
      // Try to get Thailand timezone, fallback to UTC if not available
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
      } catch (e) {
        print('Thailand timezone not found, using UTC: $e');
        tz.setLocalLocation(tz.UTC);
      }
    } catch (e) {
      print('Error initializing timezone: $e');
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> _configureNotificationSettings() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Create notification channel for Android
      if (Platform.isAndroid) {
        await _createNotificationChannel();
      }
    } catch (e) {
      print('Error configuring notification settings: $e');
      throw e;
    }
  }

  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _taskChannelId,
      _taskChannelName,
      description: _taskChannelDescription,
      importance: Importance.high,
      enableVibration: true,
      enableLights: true,
      ledColor: Color.fromARGB(255, 107, 78, 255),
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    print('Notification tapped with payload: $payload');
    
    // Navigate to task or perform action based on payload
    if (payload != null) {
      if (payload.startsWith('task_')) {
        final taskId = payload.replaceFirst('task_', '');
        // Navigate to task detail or home page
        Get.toNamed('/home'); // or Get.toNamed('/task/$taskId')
      } else if (payload.startsWith('reminder_')) {
        final taskId = payload.replaceFirst('reminder_', '');
        Get.toNamed('/home');
      }
    }
  }

  Future<void> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        // Request notification permission
        final status = await Permission.notification.request();
        permissionStatus.value = status.toString();
        
        // Request exact alarm permission for Android 12+
        if (Platform.isAndroid) {
          try {
            await Permission.scheduleExactAlarm.request();
          } catch (e) {
            print('Schedule exact alarm permission not available: $e');
          }
        }
      } else if (Platform.isIOS) {
        // For iOS, request permissions through the plugin
        final granted = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
              critical: false,
            );
        
        permissionStatus.value = granted == true ? 'granted' : 'denied';
      }
    } catch (e) {
      print('Error requesting permissions: $e');
      permissionStatus.value = 'error';
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

  void toggleNotifications() {
    notificationsEnabled.value = !notificationsEnabled.value;
  }

  Future<void> saveNotificationSetting(bool enabled) async {
    notificationsEnabled.value = enabled;
    await _saveNotificationSetting(enabled);
  }

  Future<bool> scheduleTaskNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    String? sound,
  }) async {
    try {
      // Check if notifications are enabled
      if (!notificationsEnabled.value) {
        print('Notifications are disabled by user');
        return false;
      }

      // Check if controller is initialized
      if (!isInitialized.value) {
        print('NotificationController not initialized');
        await _initializeNotifications();
        if (!isInitialized.value) {
          return false;
        }
      }

      // Check if scheduled time is in the future
      if (scheduledTime.isBefore(DateTime.now())) {
        print('Scheduled time is in the past: $scheduledTime');
        return false;
      }

      // Check permissions
      final hasPermission = await areNotificationsAllowed();
      if (!hasPermission) {
        print('Notification permission not granted');
        return false;
      }

      // Configure notification details
      final androidDetails = AndroidNotificationDetails(
        _taskChannelId,
        _taskChannelName,
        channelDescription: _taskChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color.fromARGB(255, 107, 78, 255),
        enableVibration: true,
        enableLights: true,
        ledColor: const Color.fromARGB(255, 107, 78, 255),
        ledOnMs: 1000,
        ledOffMs: 500,
        autoCancel: true,
        ongoing: false,
        styleInformation: const BigTextStyleInformation(''),
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: sound,
        interruptionLevel: InterruptionLevel.active,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Convert to timezone-aware datetime
      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);
      
      // Schedule the notification
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        notificationDetails,
        payload: payload ?? 'task_$id',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('Notification scheduled successfully for: ${tzDateTime.toString()}');
      print('Current time: ${DateTime.now()}');
      print('Time until notification: ${scheduledTime.difference(DateTime.now()).inMinutes} minutes');
      
      return true;
      
    } catch (e) {
      print('Error scheduling notification: $e');
      return false;
    }
  }

  Future<bool> scheduleTaskWithTime({
    required int taskId,
    required String title,
    required String description,
    required DateTime taskDate,
    TimeOfDay? startTime,
    int notifyBeforeMinutes = 15,
  }) async {
    try {
      DateTime scheduledTime;
      
      if (startTime != null) {
        // If task has specific start time, schedule notification before it
        scheduledTime = DateTime(
          taskDate.year,
          taskDate.month,
          taskDate.day,
          startTime.hour,
          startTime.minute,
        ).subtract(Duration(minutes: notifyBeforeMinutes));
      } else {
        // If it's an all-day task, schedule for beginning of the day
        scheduledTime = DateTime(
          taskDate.year,
          taskDate.month,
          taskDate.day,
          8, 0, // 8:00 AM
        );
      }

      // Only schedule if the time is in the future
      if (scheduledTime.isAfter(DateTime.now())) {
        String notificationTitle;
        String notificationBody;
        
        if (startTime != null) {
          notificationTitle = '🔔 Task Reminder: $title';
          notificationBody = 'Starting in $notifyBeforeMinutes minutes at ${startTime.format(Get.context!)}';
        } else {
          notificationTitle = '📅 Today\'s Task: $title';
          notificationBody = description.isNotEmpty ? description : 'You have a task scheduled for today';
        }

        return await scheduleTaskNotification(
          id: taskId,
          title: notificationTitle,
          body: notificationBody,
          scheduledTime: scheduledTime,
          payload: 'task_$taskId',
        );
      } else {
        print('Task time is in the past, not scheduling notification');
        return false;
      }
    } catch (e) {
      print('Error scheduling task notification: $e');
      return false;
    }
  }

  Future<List<bool>> scheduleTaskWithMultipleReminders({
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
        reminderBody = 'Task due in ${reminders[i].inDays} day(s)';
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

  Future<bool> cancelTaskNotifications(int taskId) async {
    try {
      // Cancel main notification
      await _notificationsPlugin.cancel(taskId);
      
      // Cancel reminder notifications (assuming they use taskId + 1, +2, +3)
      for (int i = 1; i <= 3; i++) {
        await _notificationsPlugin.cancel(taskId + i);
      }
      
      print('All notifications for task $taskId cancelled');
      return true;
    } catch (e) {
      print('Error cancelling task notifications: $e');
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

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      print('Error getting pending notifications: $e');
      return [];
    }
  }

  Future<bool> areNotificationsAllowed() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        return status.isGranted;
      } else if (Platform.isIOS) {
        final granted = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        return granted == true;
      }
      return false;
    } catch (e) {
      print('Error checking notification permissions: $e');
      return false;
    }
  }

  Future<bool> requestNotificationPermissions() async {
    try {
      if (await areNotificationsAllowed()) return true;
      
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        permissionStatus.value = status.toString();
        return status.isGranted;
      } else if (Platform.isIOS) {
        final granted = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        permissionStatus.value = granted == true ? 'granted' : 'denied';
        return granted == true;
      }
      
      return false;
    } catch (e) {
      print('Error requesting notification permissions: $e');
      return false;
    }
  }

  // Helper method to schedule immediate test notification
  Future<bool> scheduleTestNotification({int delaySeconds = 5}) async {
    return await scheduleTaskNotification(
      id: 999,
      title: 'Test Notification 🔔',
      body: 'This is a test notification. Your notifications are working!',
      scheduledTime: DateTime.now().add(Duration(seconds: delaySeconds)),
      payload: 'test_notification',
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}