import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/tasks_model.dart';
import '../services/storage_service.dart';
import 'creattask.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  TaskType? _selectedTypeFilter;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await StorageService.loadTasks();
      setState(() {
        _tasks = tasks;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    List<Task> filtered = List.from(_tasks);

    // Apply status filter
    switch (_selectedFilter) {
      case 'pending':
        filtered = filtered.where((task) => !task.isDone).toList();
        break;
      case 'completed':
        filtered = filtered.where((task) => task.isDone).toList();
        break;
      case 'today':
        final today = DateTime.now();
        filtered = filtered
            .where(
              (task) =>
                  task.date.year == today.year &&
                  task.date.month == today.month &&
                  task.date.day == today.day,
            )
            .toList();
        break;
      case 'upcoming':
        final now = DateTime.now();
        final nextWeek = now.add(const Duration(days: 7));
        filtered = filtered
            .where(
              (task) => task.date.isAfter(now) && task.date.isBefore(nextWeek),
            )
            .toList();
        break;
    }

    // Apply type filter
    if (_selectedTypeFilter != null) {
      filtered = filtered
          .where((task) => task.type == _selectedTypeFilter)
          .toList();
    }

    // Sort by date and time
    filtered.sort((a, b) {
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;

      if (a.startTime != null && b.startTime != null) {
        final aMinutes = a.startTime!.hour * 60 + a.startTime!.minute;
        final bMinutes = b.startTime!.hour * 60 + b.startTime!.minute;
        return aMinutes.compareTo(bMinutes);
      }

      return 0;
    });

    setState(() => _filteredTasks = filtered);
  }

  Future<void> _toggleTaskStatus(Task task) async {
    try {
      await StorageService.toggleTaskStatus(task.id);
      await _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบ "${task.title}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await StorageService.deleteTask(task.id);
        await _loadTasks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ลบ Task เรียบร้อยแล้ว')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาดในการลบ: $e')));
        }
      }
    }
  }

  Widget _buildTaskCard(Task task) {
    final isOverdue = task.date.isBefore(DateTime.now()) && !task.isDone;
    final isToday =
        task.date.year == DateTime.now().year &&
        task.date.month == DateTime.now().month &&
        task.date.day == DateTime.now().day;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: task.isDone ? 1 : 2,
      color: task.isDone
          ? Colors.grey[100]
          : isOverdue
          ? Colors.red[50]
          : isToday
          ? Colors.blue[50]
          : null,
      child: ListTile(
        leading: Checkbox(
          value: task.isDone,
          onChanged: (_) => _toggleTaskStatus(task),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isDone ? Colors.grey : null,
            fontWeight: task.isDone ? FontWeight.normal : FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description?.isNotEmpty == true)
              Text(
                task.description!,
                style: TextStyle(
                  color: task.isDone ? Colors.grey : Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _getTaskTypeIcon(task.type),
                  size: 16,
                  color: _getTaskTypeColor(task.type),
                ),
                const SizedBox(width: 4),
                Text(
                  _getTaskTypeText(task.type),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getTaskTypeColor(task.type),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  task.category,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatTaskTime(task),
                  style: TextStyle(
                    fontSize: 12,
                    color: isOverdue ? Colors.red : Colors.grey[600],
                    fontWeight: isOverdue ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                if (task.focusMode) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Focus',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.purple[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delete':
                _deleteTask(task);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('ลบ'),
                ],
              ),
            ),
          ],
        ),
        onTap: task.isDone ? null : () => _toggleTaskStatus(task),
      ),
    );
  }

  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.work:
        return Icons.work;
      case TaskType.birthday:
        return Icons.cake;
      case TaskType.even:
      default:
        return Icons.event;
    }
  }

  Color _getTaskTypeColor(TaskType type) {
    switch (type) {
      case TaskType.work:
        return Colors.orange;
      case TaskType.birthday:
        return Colors.pink;
      case TaskType.even:
      default:
        return Colors.blue;
    }
  }

  String _getTaskTypeText(TaskType type) {
    switch (type) {
      case TaskType.work:
        return 'งาน';
      case TaskType.birthday:
        return 'วันเกิด';
      case TaskType.even:
      default:
        return 'กิจกรรม';
    }
  }

  String _formatTaskTime(Task task) {
    final dateFormat = DateFormat('d MMM yyyy', 'th');
    String result = dateFormat.format(task.date);

    if (!task.isAllDay && task.startTime != null) {
      result += ' ${task.startTime!.format(context)}';
      if (task.endTime != null) {
        result += ' - ${task.endTime!.format(context)}';
      }
    } else if (task.isAllDay) {
      result += ' (ทั้งวัน)';
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการ Tasks'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _selectedFilter = value);
              _applyFilters();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('ทั้งหมด')),
              const PopupMenuItem(value: 'pending', child: Text('รอดำเนินการ')),
              const PopupMenuItem(value: 'completed', child: Text('เสร็จแล้ว')),
              const PopupMenuItem(value: 'today', child: Text('วันนี้')),
              const PopupMenuItem(
                value: 'upcoming',
                child: Text('ใน 7 วันข้างหน้า'),
              ),
            ],
            child: const Icon(Icons.filter_list),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('ทั้งหมด'),
                          selected: _selectedTypeFilter == null,
                          onSelected: (_) {
                            setState(() => _selectedTypeFilter = null);
                            _applyFilters();
                          },
                        ),
                        const SizedBox(width: 8),
                        ...TaskType.values.map(
                          (type) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(_getTaskTypeText(type)),
                              selected: _selectedTypeFilter == type,
                              onSelected: (_) {
                                setState(
                                  () => _selectedTypeFilter =
                                      _selectedTypeFilter == type ? null : type,
                                );
                                _applyFilters();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredTasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'ไม่มี Tasks',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'เริ่มสร้าง Task แรกของคุณ!',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: ListView.builder(
                itemCount: _filteredTasks.length,
                itemBuilder: (context, index) =>
                    _buildTaskCard(_filteredTasks[index]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTaskPage()),
          );
          if (result != null) {
            await _loadTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
