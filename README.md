
# 📝 Timo Flow – Flutter To-Do List App

Timo Flow คือแอป Flutter สำหรับจัดการ Task อย่างครบวงจร พร้อมฟีเจอร์แจ้งเตือน, Focus Mode, การจัดกลุ่มงาน และบัญชีผู้ใช้  
ออกแบบด้วยแนวคิด pastel-minimal UI ที่เหมาะทั้งสำหรับมือถือและเว็บ

---

## 🧠 หลักการทำงานของระบบ

แอปใช้ GetX ในการจัดการสถานะและ navigation  
ข้อมูลผู้ใช้และ Task ถูกจัดเก็บแบบ local ผ่าน SharedPreferences  
ระบบแจ้งเตือนใช้ `flutter_local_notifications` ร่วมกับ `timezone`

---

### 🔄 การจัดการสถานะ (State Management)

ใช้ `GetX` controller หลัก 3 ตัว:

```dart
Get.put(AuthController());
Get.put(TaskController());
Get.put(NotificationController());
```

| Controller | หน้าที่ |
|------------|---------|
| `AuthController` | จัดการบัญชีผู้ใช้ |
| `TaskController` | สร้าง/ลบ/แก้ไข Task ทั้งหมด |
| `NotificationController` | จัดการระบบแจ้งเตือนแบบละเอียด |

---

## 🔧 โครงสร้าง Model

### Task Model
```dart
class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String type; // event, goal, birthday
  final DateTime? date;
  final String? startTime;
  final String? endTime;
  final bool isAllDay;
  final bool isDone;
  final bool focusMode;
  final List<int>? notifyBefore;
  final String? category;

  Task({ required this.id, required this.userId, ... });

  factory Task.fromJson(Map<String, dynamic> json) => Task(...);
  Map<String, dynamic> toJson() => {...};
}
```

**หน้าที่ของแต่ละฟิลด์:**
- `type`: กำหนดพฤติกรรม Task (เช่น Goal จะมีติ๊ก ✔ ได้)
- `focusMode`: ทำให้แสดง countdown ใน Task Detail
- `notifyBefore`: แจ้งเตือนก่อนเวลาตามที่เลือก (5-1440 นาที)

---

## 🧱 หน้า Home (Calendar + Task List)

ใช้ `TableCalendar` แสดงวันและ Task ที่เกี่ยวข้อง

```dart
TableCalendar(
  firstDay: DateTime(2020),
  lastDay: DateTime(2077),
  focusedDay: focusedDay,
  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
  eventLoader: (day) => taskController.getTasksByDate(day),
);
```

- ผู้ใช้สามารถสลับเป็นโหมด "4 วันถัดไป"
- มี FAB สำหรับเพิ่ม Task ใหม่แบบ 3 ประเภท

---

## ➕ สร้าง Task ใหม่

```dart
Task newTask = Task(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  userId: authController.currentUser!.id,
  title: title,
  type: 'goal',
  date: selectedDate,
  startTime: '10:00',
  endTime: '12:00',
  focusMode: true,
  notifyBefore: [10, 60],
  category: 'Work',
);

await taskController.addTask(newTask);
await notificationController.scheduleTaskWithTime(task: newTask);
```

- รองรับ: ทั้งวัน / มีเวลา / แจ้งเตือนล่วงหน้า
- Focus Mode จะบังคับกรอกเวลาเริ่ม/จบ และปิด "ทั้งวัน" อัตโนมัติ

---

## 🔔 การทำงานของระบบแจ้งเตือน

```dart
Future<void> scheduleTaskWithTime(Task task) async {
  for (final minutes in task.notifyBefore ?? []) {
    final scheduledTime = task.date!.subtract(Duration(minutes: minutes));
    await flutterLocalNotificationsPlugin.zonedSchedule(
      ... // ตั้งเวลาแจ้งเตือนโดยใช้ timezone
    );
  }
}
```

- ใช้ `flutter_local_notifications` ผนวกกับ `timezone`
- ผู้ใช้สามารถเลือกแจ้งเตือนได้หลายช่วงเวลา

---

## 🎯 Focus Mode

- ใช้ได้เฉพาะกับ Goal
- ปิด All-Day และต้องมีเวลาเริ่ม-จบ
- เมื่อเข้า Task Detail จะแสดงนาฬิกานับถอยหลัง

```dart
if (task.focusMode) {
  showCountdown(task.startTime, task.endTime);
}
```

---

## 📄 Task Details Page

แสดงรายละเอียดแบบเต็ม พร้อม action:
- ✅ Done (เฉพาะ Goal)
- ✏️ Edit
- 🗑️ Delete

ถ้าเป็น Focus Mode → แสดง Countdown

---

## 🔍 Search & Filter Page

```dart
List<Task> filtered = tasks.where((task) =>
  task.title.contains(query) &&
  (selectedCategory == null || task.category == selectedCategory) &&
  (selectedDate == null || isSameDay(task.date, selectedDate))
).toList();
```

- ค้นหาจากชื่อ Task
- กรองตามวันที่ / ประเภท / หมวดหมู่

---

## ✅ Task Completion Toggle

- ใช้เฉพาะ Goal ที่ถูกติ๊ก ✔ แล้ว
- Task ที่เสร็จแล้วจะถูกลบหลัง 1 วัน

---

## ⚙️ Settings Page

- เปลี่ยนชื่อ / รูปโปรไฟล์
- เปลี่ยนรหัสผ่าน
- Logout
- ตั้งค่าเปิด/ปิดแจ้งเตือน

---

## 🛠 โครงสร้างโฟลเดอร์

```
lib/
├── main.dart
├── controllers/
│   ├── auth_controller.dart
│   ├── task_controller.dart
│   └── notification_controller.dart
├── model/
│   └── task_model.dart
├── screens/
│   ├── home/
│   ├── create_task/
│   ├── edit_task/
│   ├── task_detail/
│   └── settings/
├── components/
│   └── reusable widgets
├── routes/
│   └── app_pages.dart
└── services/ (ถ้ามี)
```

---

## ✅ ความสามารถเด่น

| Feature | Description |
|--------|-------------|
| 🔔 Notification | แจ้งเตือนแบบกำหนดเวลาได้ล่วงหน้า |
| 🎯 Focus Mode | พร้อม countdown timer |
| 📆 Calendar View | ปฏิทินพร้อมแสดง Task รายวัน |
| 🧠 Goal Completion | ติ๊กเสร็จ → ลบอัตโนมัติ |
| 🔍 Filter/Search | ค้นหาทันทีพร้อมกรองหมวดหมู่ |
| 👤 Account Binding | Task ผูกกับบัญชีผู้ใช้แต่ละคน |

---

## 🧪 ตัวอย่าง Task

```json
{
  "id": "1691234567890",
  "userId": "u01",
  "title": "ทบทวนบทที่ 5",
  "type": "goal",
  "date": "2025-08-10",
  "startTime": "08:00",
  "endTime": "09:30",
  "focusMode": true,
  "notifyBefore": [10, 30],
  "category": "Math"
}
```

---

## ▶ วิธีเริ่มต้นใช้งาน

```bash
flutter pub get
flutter run
```

---

``` Dart
dependencies:
  flutter:
    sdk: flutter
  get: ^4.7.2                     # จัดการสถานะและ route
  path_provider: ^2.1.3           # เข้าถึง path เก็บไฟล์บน device
  intl: ^0.20.2                   # จัดการรูปแบบวันที่/เวลา
  shared_preferences: ^2.2.2      # เก็บข้อมูลผู้ใช้แบบ local
  table_calendar: ^3.0.8          # ปฏิทินแสดง task รายวัน
  image_picker: ^1.0.5            # เลือกรูปโปรไฟล์
  flutter_local_notifications: ^19.4.0 # ระบบแจ้งเตือน
  permission_handler: ^12.0.1     # ขอสิทธิ์แจ้งเตือน/กล้อง
  top_snackbar_flutter: ^3.1.0    # แสดง snackbar ด้านบน
  overlay_support: ^2.1.0         # ระบบแจ้งเตือน overlay
  timezone: ^0.10.1               # จัดการ timezone 
  ```
