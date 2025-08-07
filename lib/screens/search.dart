import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../model/tasks_model.dart';
import '../services/universal_storage_service.dart';
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
    loadTasks();
  }

  Future<void> loadTasks() async {
    final tasks = await StorageService.loadTasks();
    tasks.sort((a, b) => a.date.compareTo(b.date));
    setState(() {
      allTasks = tasks;
      filteredTasks = tasks;
    });
  }

  void filterTasks() {
    String query = searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        filteredTasks = [];
      } else {
        filteredTasks = allTasks.where((task) {
          final matchesText =
              task.title.toLowerCase().contains(query) ||
              (task.description?.toLowerCase().contains(query) ?? false);

          final matchesDate =
              selectedDate == null ||
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B4EFF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF6B4EFF),
            ),
          ),
          child: child!,
        );
      },
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
      // ใน SearchScreen - AppBar ที่ปรับปรุงแล้ว
      appBar: AppBar(
        backgroundColor: primaryPastel,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF6B4EFF)),
        centerTitle: true,
        leading: Container(
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
              Icons.arrow_back,
              color: Color(0xFF6B4EFF),
              size: 22,
            ),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            splashRadius: 20,
          ),
        ),
        title: const Text(
          'Search Tasks',
          style: TextStyle(
            color: Color(0xFF6B4EFF),
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          // Date Filter Button
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selectedDate != null
                  ? const Color(0xFF6B4EFF)
                  : Colors.white,
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
              icon: Icon(
                Icons.calendar_today,
                color: selectedDate != null
                    ? Colors.white
                    : const Color(0xFF6B4EFF),
                size: 22,
              ),
              onPressed: pickDate,
              padding: EdgeInsets.zero,
              splashRadius: 20,
            ),
          ),
          // Clear Date Button
          if (selectedDate != null)
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
                  Icons.clear,
                  color: Color(0xFF6B4EFF),
                  size: 22,
                ),
                onPressed: clearDate,
                padding: EdgeInsets.zero,
                splashRadius: 20,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardPastel,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Tasks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B4EFF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search by title or description...",
                      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF6B4EFF),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6B4EFF),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                    ),
                    onChanged: (_) => filterTasks(),
                  ),
                  if (selectedDate != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: primaryPastel,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF6B4EFF),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Filter: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}",
                            style: const TextStyle(
                              color: Color(0xFF6B4EFF),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: clearDate,
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFF6B4EFF),
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Results Section
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: primaryPastel.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            searchController.text.isEmpty
                                ? Icons.search
                                : Icons.search_off,
                            size: 64,
                            color: const Color(0xFF6B4EFF),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchController.text.isEmpty
                              ? 'Start typing to search'
                              : 'No tasks found',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF9E9E9E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          searchController.text.isEmpty
                              ? 'Enter task title or description'
                              : 'Try a different search term',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
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
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.type.name[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ),
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
                                    fontSize: 13,
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
                                      DateFormat(
                                        'dd MMM yyyy',
                                      ).format(task.date),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: accentColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
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
                                      task.category,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: accentColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
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
                              : Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.chevron_right,
                                    color: accentColor,
                                    size: 20,
                                  ),
                                ),
                          onTap: () async {
                            await Get.to(() => TaskDetail(task: task));
                            await loadTasks();
                            filterTasks();
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
