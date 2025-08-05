import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/intl.dart';
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
  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime? _selectedDay;
  final TaskController _taskController = Get.put(TaskController());
  final authController = Get.find<AuthController>();
  String? userId;

  @override
  void initState() {
    super.initState();
    _selectedDay = null;
    userId = authController.currentUser.value?.id;
    if (userId != null) {
      _taskController.loadTasksForUser(userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;

    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left),
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month - 1,
                    1,
                  );
                });
              },
            ),
            Expanded(
              child: Center(
                child: DropdownButton<DateTime>(
                  value: _selectedMonth,
                  underline: const SizedBox(),
                  items: List.generate(12, (i) {
                    final date = DateTime(DateTime.now().year, i + 1, 1);
                    return DropdownMenuItem(
                      value: date,
                      child: Text(DateFormat.yMMMM().format(date)),
                    );
                  }),
                  onChanged: (date) {
                    if (date != null) setState(() => _selectedMonth = date);
                  },
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_right),
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month + 1,
                    1,
                  );
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // ไปหน้า search/filter
              },
            ),
            IconButton(
              icon: const Icon(Icons.check_box),
              onPressed: () {
                // ไปหน้า Task Completion Toggle
              },
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Calendar (บน)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Card(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    DateFormat.yMMMM().format(_selectedMonth),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(daysInMonth, (index) {
                      final day = index + 1;
                      final isSelected =
                          _selectedDay?.day == day &&
                          _selectedDay?.month == _selectedMonth.month &&
                          _selectedDay?.year == _selectedMonth.year;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDay = DateTime(
                              _selectedMonth.year,
                              _selectedMonth.month,
                              day,
                            );
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.pink[100] : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.pinkAccent
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Text('$day'),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          // Tasks (ล่าง)
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
                    ..sort(
                      (a, b) => a.date!.compareTo(b.date!),
                    ); // sort ตามวันที่

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            // Get.to(() => const MyDrawer());
                          },
                        ),
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
                              final dateText = DateFormat(
                                'dd MMMM yyyy',
                              ).format(task.date); // <-- วันที่ภาษาอังกฤษ

                              return Card(
                                color: task.type == TaskType.birthday
                                    ? Colors.blue[50]
                                    : task.type == TaskType.even
                                    ? Colors.pink[50]
                                    : Colors.purple[50],
                                child: ListTile(
                                  title: Text(task.title),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
