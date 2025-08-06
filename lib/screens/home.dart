import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controllers/task_controller.dart';
import '../components/drawer.dart';
import 'creattask.dart';
import '../model/tasks_model.dart';
import '../controllers/auth_controller.dart';
import 'task_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskController _taskController = Get.put(TaskController());
  final authController = Get.find<AuthController>();

  String? userId;

  // วันที่ที่ปฏิทินกำลังโฟกัส (แสดง)
  DateTime _focusedDay = DateTime.now();

  // วันที่ถูกเลือก เพื่อแสดง task
  DateTime? _selectedDay;

  // โหมดแสดงปฏิทิน: false = เดือนเต็ม, true = แสดง 4 วัน
  bool _showFewDays = false;

  @override
  void initState() {
    super.initState();
    userId = authController.currentUser.value?.id;
    if (userId != null) {
      _taskController.loadTasksForUser(userId!);
    }
    _selectedDay = _focusedDay;
  }

  // สร้าง List ของวันที่จะใช้แสดงในโหมด 4 วัน (เช่น เลือกวันไหน ก็แสดงวันนั้น + 3 วันถัดไป)
  List<DateTime> get _fewDaysList {
    return List.generate(4, (index) => _focusedDay.add(Duration(days: index)));
  }

  // ฟังก์ชันเปลี่ยนเดือนและปีผ่าน dropdown
  void _onMonthYearChanged(DateTime newDate) {
    setState(() {
      _focusedDay = DateTime(newDate.year, newDate.month, _focusedDay.day);
      _selectedDay = _focusedDay;
    });
  }

  // สร้าง Dropdown รายเดือน + ปี ใน AppBar ด้านขวา
  Widget _buildMonthYearDropdown() {
    // สร้าง list ปีปัจจุบัน +/- 5 ปี
    final currentYear = DateTime.now().year;
    final years = List.generate(11, (i) => currentYear - 5 + i);

    // สร้าง list เดือน 1-12
    final months = List.generate(12, (i) => i + 1);

    return Row(
      children: [
        DropdownButton<int>(
          value: _focusedDay.month,
          underline: const SizedBox(),
          items: months
              .map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(DateFormat.MMMM().format(DateTime(0, m))),
                  ))
              .toList(),
          onChanged: (month) {
            if (month != null) {
              _onMonthYearChanged(DateTime(_focusedDay.year, month, 1));
            }
          },
        ),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: _focusedDay.year,
          underline: const SizedBox(),
          items: years
              .map((y) => DropdownMenuItem(
                    value: y,
                    child: Text('$y'),
                  ))
              .toList(),
          onChanged: (year) {
            if (year != null) {
              _onMonthYearChanged(DateTime(year, _focusedDay.month, 1));
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // ถ้าโหมดเดือนเต็ม ให้แสดง Task ตามวันที่เลือกปกติ
    // ถ้าโหมด 4 วัน Task list แสดง task ของวันที่เลือก (_selectedDay)
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Timo Flow', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.check_box),
            onPressed: () {},
          ),
          // ปุ่ม All Task toggle
          TextButton(
            onPressed: () {
              setState(() {
                _showFewDays = !_showFewDays;
                if (!_showFewDays) {
                  // ถ้าออกจากโหมด 4 วัน ให้เลือกวันแรกของเดือนที่โฟกัส
                  _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
                } else {
                  // ถ้าเข้าโหมด 4 วัน ให้เลือก focusedDay เป็นวันที่เลือก
                  _selectedDay = _focusedDay;
                }
              });
            },
            child: Text(
              _showFewDays ? 'All Task' : 'Few Days',
              style: const TextStyle(color: Colors.black),
            ),
          ),
          // Dropdown เดือน-ปี
          _buildMonthYearDropdown(),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 2,
              child: Column(
                children: [
                  // ถ้าโหมดเดือนเต็ม
                  if (!_showFewDays)
                    TableCalendar(
                      firstDay: DateTime(2020, 1, 1),
                      lastDay: DateTime(2077, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.pink[200],
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                    ),

                  // ถ้าโหมด 4 วัน (showFewDays == true)
                  if (_showFewDays)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_left),
                          onPressed: () {
                            setState(() {
                              // เลื่อนไป 1 วันย้อนหลัง
                              _focusedDay = _focusedDay.subtract(const Duration(days: 1));
                            });
                          },
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 70,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _fewDaysList.length,
                              itemBuilder: (context, index) {
                                final day = _fewDaysList[index];
                                final isSelected = isSameDay(_selectedDay, day);

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDay = day;
                                    });
                                  },
                                  child: Container(
                                    width: 60,
                                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.pink[200] : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? Colors.pinkAccent : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          DateFormat.E().format(day), // เช่น จ, อ, พ
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          day.day.toString(),
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_right),
                          onPressed: () {
                            setState(() {
                              // เลื่อนไป 1 วันข้างหน้า
                              _focusedDay = _focusedDay.add(const Duration(days: 1));
                            });
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Task list ด้านล่าง
          Expanded(
            child: Obx(() {
              final now = DateTime.now();
              final tasks = _selectedDay != null
                  ? _taskController
                      .filterByDate(_selectedDay!)
                      .where((task) => task.userId == userId)
                      .toList()
                  : _taskController.tasks
                      .where(
                        (task) =>
                            task.userId == userId &&
                            task.date != null &&
                            !task.date!.isBefore(
                              DateTime(now.year, now.month, now.day),
                            ),
                      )
                      .toList()
                ..sort((a, b) => a.date!.compareTo(b.date!));

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tasks',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        // คุณจะเพิ่มปุ่มอื่นๆ ในแถวนี้ได้ เช่น filter ได้
                      ],
                    ),
                  ),
                  Expanded(
                    child: tasks.isEmpty
                        ? const Center(child: Text('No tasks available'))
                        : ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              final dateText =
                                  DateFormat('dd MMMM yyyy').format(task.date);

                              return Card(
                                color: task.type == TaskType.birthday
                                    ? Colors.blue[50]
                                    : task.type == TaskType.even
                                        ? Colors.pink[50]
                                        : Colors.purple[50],
                                child: ListTile(
                                  title: Text(task.title),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (task.description != null &&
                                          task.description!.isNotEmpty)
                                        Text(task.description!),
                                      Text(
                                        dateText,
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    task.startTime != null
                                        ? '${task.startTime!.hour.toString().padLeft(2, '0')}:${task.startTime!.minute.toString().padLeft(2, '0')}'
                                        : '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    Get.to(() => TaskDetail(task: task));
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.pinkAccent,
      child: const Icon(Icons.add),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => _buildFABMenu(context),
        );
      },
    );
  }

  Widget _buildFABMenu(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _fabModeButton(context, TaskType.even, Colors.pink[200]!),
          _fabModeButton(context, TaskType.goal, Colors.purple[200]!),
          _fabModeButton(context, TaskType.birthday, Colors.blue[200]!),
        ],
      ),
    );
  }

  Widget _fabModeButton(BuildContext context, TaskType type, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: type.name,
          backgroundColor: color,
          child: Text(type.name[0].toUpperCase()),
          onPressed: () {
            Navigator.pop(context);
            Get.to(() => CreatTaskPage(initialType: type));
          },
        ),
        const SizedBox(height: 8),
        Text(type.name),
      ],
    );
  }
}
