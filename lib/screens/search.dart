import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../model/tasks_model.dart';
import '../services/universal_storage_service.dart'; // เรียก universal_storage
import 'task_detail.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Task> allTasks = [];
  List<Task> filteredTasks = [];

  final TextEditingController searchController = TextEditingController();

  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final tasks = await StorageService.loadTasks();
    tasks.sort((a, b) => a.date.compareTo(b.date)); // เรียงตามวัน
    setState(() {
      allTasks = tasks;
      filteredTasks = tasks;
    });
  }

  void filterTasks() {
    String query = searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        // ถ้าช่องค้นหาว่างเลย ให้แสดงรายการว่างเลย
        filteredTasks = [];
      } else {
        // กรองตามข้อความและวันที่
        filteredTasks = allTasks.where((task) {
          final matchesText = task.title.toLowerCase().contains(query) ||
              (task.description?.toLowerCase().contains(query) ?? false);

          final matchesDate = selectedDate == null ||
              (task.date.year == selectedDate!.year &&
                  task.date.month == selectedDate!.month &&
                  task.date.day == selectedDate!.day);

          return matchesText && matchesDate;
        }).toList();
      }
    });
  }


  void pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      filterTasks();
    }
  }

  void clearDate() {
    setState(() {
      selectedDate = null;
    });
    filterTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ค้นหา Task"),
        backgroundColor: const Color(0xFFADBFFF),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: pickDate,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: clearDate,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "ค้นหา...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Color(0xFFEFEFEF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: (_) => filterTasks(),
            ),
          ),
          if (selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "กรองโดยวันที่: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(child: Text("ไม่พบ Task ที่ตรงกับการค้นหา"))
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Card(
                        color: const Color(0xFFFDC2B4),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Text(DateFormat('dd MMM yyyy')
                              .format(task.date)
                              .toString()),
                          // trailing: task.isDone
                          //     ? const Icon(Icons.check_circle, color: Colors.green)
                          //     : null,
                          onTap: () async {
                            await Get.to(() => TaskDetail(task: task));
                            await loadTasks(); // โหลดใหม่หลังกลับมา
                            filterTasks();     // ฟิลเตอร์ใหม่
                          },

                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
