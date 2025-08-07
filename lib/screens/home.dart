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
import '../screens/search.dart';
import '../screens/toggle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskController _taskController = Get.put(TaskController());
  final authController = Get.find<AuthController>();

  String? userId;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showFewDays = false;

  late int _selectedMonth;
  late int _selectedYear;

  // Color scheme
  static const Color primaryPastel = Color(0xFFE8D5FF);
  static const Color backgroundPastel = Color(0xFFF8F6FF);
  static const Color cardPastel = Color(0xFFFFFBFF);
  static const Color accentBlue = Color(0xFFE3F2FD);
  static const Color accentPink = Color(0xFFFFE4E6);
  static const Color accentPurple = Color(0xFFF3E5F5);

  @override
  void initState() {
    super.initState();
    userId = authController.currentUser.value?.id;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _selectedMonth = _focusedDay.month;
    _selectedYear = _focusedDay.year;

    if (userId != null) {
      _taskController.loadTasksForUser(userId!).then((_) {
        setState(() {
          _focusedDay = DateTime.now();
          _selectedDay = DateTime.now();
          _selectedMonth = _focusedDay.month;
          _selectedYear = _focusedDay.year;
        });
      });
    }
  }

  void _onMonthYearChanged(DateTime newDate) {
    setState(() {
      _selectedYear = newDate.year;
      _selectedMonth = newDate.month;
      _focusedDay = DateTime(_selectedYear, _selectedMonth, 1);
    });
  }

  Widget _buildMonthYearDropdown() {
    final firstYear = 2020;
    final lastYear = 2077;
    final years = List.generate(lastYear - firstYear + 1, (i) => firstYear + i);
    final months = List.generate(12, (i) => i + 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<int>(
            value: _selectedMonth,
            underline: const SizedBox(),
            style: const TextStyle(
              color: Color(0xFF6B4EFF),
              fontWeight: FontWeight.w500,
            ),
            items: months
                .map(
                  (m) => DropdownMenuItem(
                    value: m,
                    child: Text(DateFormat.MMMM().format(DateTime(0, m))),
                  ),
                )
                .toList(),
            onChanged: (month) {
              if (month != null) {
                _onMonthYearChanged(DateTime(_selectedYear, month, 1));
              }
            },
          ),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: _selectedYear,
            underline: const SizedBox(),
            style: const TextStyle(
              color: Color(0xFF6B4EFF),
              fontWeight: FontWeight.w500,
            ),
            items: years
                .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                .toList(),
            onChanged: (year) {
              if (year != null) {
                _onMonthYearChanged(DateTime(year, _selectedMonth, 1));
              }
            },
          ),
        ],
      ),
    );
  }

  List<DateTime> get _fewDaysList {
    return List.generate(4, (index) => _focusedDay.add(Duration(days: index)));
  }

  Color _getTaskTypeColor(TaskType type, bool isBackground) {
    switch (type) {
      case TaskType.even:
        return isBackground ? accentPink : const Color(0xFFD81B60);
      case TaskType.goal:
        return isBackground ? accentBlue : const Color(0xFF0288D1);
      case TaskType.birthday:
        return isBackground ? accentPurple : const Color(0xFF8E24AA);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPastel,
      drawer: const MyDrawer(),
      // ใน HomeScreen - AppBar ที่ปรับปรุงแล้ว
appBar: AppBar(
  backgroundColor: primaryPastel,
  elevation: 0,
  iconTheme: const IconThemeData(color: Color(0xFF6B4EFF)),
  centerTitle: true,
  leading: Builder(
    builder: (context) => Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(
          Icons.menu,
          color: Color(0xFF6B4EFF),
          size: 22,
        ),
        onPressed: () => Scaffold.of(context).openDrawer(),
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    ),
  ),
  title: const Text(
    'Timo Flow',
    style: TextStyle(
      color: Color(0xFF6B4EFF),
      fontWeight: FontWeight.w700,
      fontSize: 22,
      letterSpacing: 0.5,
    ),
  ),
  actions: [
    // Month/Year Dropdown
    Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: _buildMonthYearDropdown(),
    ),
    const SizedBox(width: 8),
    // Search Button
    Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(
          Icons.search,
          color: Color(0xFF6B4EFF),
          size: 22,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchScreen()),
          );
        },
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    ),
    // Toggle Button
    Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(
          Icons.check_box,
          color: Color(0xFF6B4EFF),
          size: 22,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ToggleScreen()),
          );
        },
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    ),
    const SizedBox(width: 8),
  ],
),
      body: Column(
        children: [
          // Calendar Section
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardPastel,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  if (!_showFewDays)
                    TableCalendar(
                      firstDay: DateTime(2020, 1, 1),
                      lastDay: DateTime(2077, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _selectedMonth = focusedDay.month;
                          _selectedYear = focusedDay.year;
                        });
                      },
                      eventLoader: (day) {
                        return _taskController.tasks.where((task) {
                          return isSameDay(task.date, day) &&
                              task.userId == userId;
                        }).toList();
                      },
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isNotEmpty) {
                            return Positioned(
                              bottom: 4,
                              child: Container(
                                height: 6,
                                width: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6B4EFF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: const BoxDecoration(
                          color: Color(0xFF6B4EFF),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: const Color(0xFF6B4EFF).withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        weekendTextStyle: const TextStyle(
                          color: Color(0xFF8E24AA),
                        ),
                        holidayTextStyle: const TextStyle(
                          color: Color(0xFF8E24AA),
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B4EFF),
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: Color(0xFF6B4EFF),
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: Color(0xFF6B4EFF),
                        ),
                      ),
                    ),
                  if (_showFewDays)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryPastel,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_left,
                                color: Color(0xFF6B4EFF),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _focusedDay = _focusedDay.subtract(
                                  const Duration(days: 1),
                                );
                                _selectedMonth = _focusedDay.month;
                                _selectedYear = _focusedDay.year;
                              });
                            },
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 100,
                              child: GestureDetector(
                                onHorizontalDragEnd: (details) {
                                  if (details.primaryVelocity == null) return;
                                  if (details.primaryVelocity! < 0) {
                                    setState(() {
                                      _focusedDay = _focusedDay.add(
                                        const Duration(days: 1),
                                      );
                                      _selectedMonth = _focusedDay.month;
                                      _selectedYear = _focusedDay.year;
                                    });
                                  } else if (details.primaryVelocity! > 0) {
                                    setState(() {
                                      _focusedDay = _focusedDay.subtract(
                                        const Duration(days: 1),
                                      );
                                      _selectedMonth = _focusedDay.month;
                                      _selectedYear = _focusedDay.year;
                                    });
                                  }
                                },
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _fewDaysList.length,
                                  itemBuilder: (context, index) {
                                    final day = _fewDaysList[index];
                                    final isSelected = isSameDay(
                                      _selectedDay,
                                      day,
                                    );
                                    final hasTask = _taskController.tasks.any(
                                      (task) =>
                                          isSameDay(task.date, day) &&
                                          task.userId == userId,
                                    );

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedDay = day;
                                        });
                                      },
                                      child: Container(
                                        width: 70,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF6B4EFF)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: isSelected
                                              ? null
                                              : Border.all(
                                                  color: const Color(
                                                    0xFFE0E0E0,
                                                  ),
                                                  width: 1,
                                                ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              DateFormat.E().format(day),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? Colors.white
                                                    : const Color(0xFF9E9E9E),
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              day.day.toString(),
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : const Color(0xFF6B4EFF),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            if (hasTask)
                                              Container(
                                                height: 4,
                                                width: 4,
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : const Color(0xFF6B4EFF),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryPastel,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_right,
                                color: Color(0xFF6B4EFF),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _focusedDay = _focusedDay.add(
                                  const Duration(days: 1),
                                );
                                _selectedMonth = _focusedDay.month;
                                _selectedYear = _focusedDay.year;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Toggle Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tasks',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Color(0xFF6B4EFF),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showFewDays = !_showFewDays;
                      });
                    },
                    icon: Icon(
                      _showFewDays ? Icons.calendar_view_month : Icons.view_day,
                      color: const Color(0xFF6B4EFF),
                      size: 18,
                    ),
                    label: Text(
                      _showFewDays ? 'Calendar' : 'Few Days',
                      style: const TextStyle(
                        color: Color(0xFF6B4EFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tasks List
          Expanded(
            child: Obx(() {
              final now = DateTime.now();
              final tasks =
                  _selectedDay != null
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

              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: primaryPastel.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.task_alt,
                          size: 64,
                          color: Color(0xFF6B4EFF),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No tasks available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create your first task!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFBDBDBD),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final dateText = DateFormat('dd MMMM yyyy').format(task.date);
                  final bgColor = _getTaskTypeColor(task.type, true);
                  final accentColor = _getTaskTypeColor(task.type, false);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: accentColor,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.description != null &&
                              task.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description!,
                              style: TextStyle(
                                color: accentColor.withOpacity(0.7),
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  dateText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: accentColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (task.focusMode) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'FOCUS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: task.startTime != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${task.startTime!.hour.toString().padLeft(2, '0')}:${task.startTime!.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        Get.to(() => TaskDetail(task: task));
                      },
                    ),
                  );
                },
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
      backgroundColor: const Color(0xFF6B4EFF),
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add, size: 28),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => _buildFABMenu(context),
        );
      },
    );
  }

  Widget _buildFABMenu(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Create New Task',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B4EFF),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _fabModeButton(
                context,
                TaskType.even,
                accentPink,
                const Color(0xFFD81B60),
              ),
              _fabModeButton(
                context,
                TaskType.goal,
                accentBlue,
                const Color(0xFF0288D1),
              ),
              _fabModeButton(
                context,
                TaskType.birthday,
                accentPurple,
                const Color(0xFF8E24AA),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _fabModeButton(
    BuildContext context,
    TaskType type,
    Color bgColor,
    Color textColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: textColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => CreatTaskPage(initialType: type));
              },
              child: Center(
                child: Text(
                  type.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          type.name.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
