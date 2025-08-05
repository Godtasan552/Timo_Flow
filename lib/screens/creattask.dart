import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/tasks_model.dart';
import '../services/storage_service.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isAllDay = false;
  bool _isFocusMode = false;
  List<int> _selectedNotifyTimes = [15]; // Default 15 minutes before
  String? _selectedCategory;
  TaskType _selectedTaskType = TaskType.even;
  List<String> _categories = [];

  // Pre-defined notification options
  final List<int> _notificationOptions = [
    0,
    5,
    10,
    15,
    30,
    60,
    120,
    1440,
  ]; // minutes

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await StorageService.loadCategories();
    setState(() {
      _categories = cats;
      if (_categories.isNotEmpty) _selectedCategory = _categories.first;
    });
  }

  Future<void> _addNewCategoryDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('เพิ่มหมวดหมู่ใหม่'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'ชื่อหมวดหมู่',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _categories.add(controller.text.trim());
                  _selectedCategory = controller.text.trim();
                });
                StorageService.saveCategories(_categories);
              }
              Navigator.pop(context);
            },
            child: const Text('เพิ่ม'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'แจ้งเตือนล่วงหน้า',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _notificationOptions.map((minutes) {
                final isSelected = _selectedNotifyTimes.contains(minutes);
                return FilterChip(
                  label: Text(_formatNotificationTime(minutes)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedNotifyTimes.add(minutes);
                      } else {
                        _selectedNotifyTimes.remove(minutes);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNotificationTime(int minutes) {
    if (minutes == 0) return 'ตอนนั้น';
    if (minutes < 60) return '$minutes นาที';
    if (minutes < 1440) return '${minutes ~/ 60} ชั่วโมง';
    return '${minutes ~/ 1440} วัน';
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกหมวดหมู่')));
      return;
    }

    // Validate time logic
    if (!_isAllDay &&
        _startTime.hour * 60 + _startTime.minute >=
            _endTime.hour * 60 + _endTime.minute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เวลาเริ่มต้องมาก่อนเวลาสิ้นสุด')),
      );
      return;
    }

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      date: _selectedDate,
      startTime: _isAllDay ? null : _startTime,
      endTime: _isAllDay ? null : _endTime,
      isAllDay: _isAllDay,
      notifyBefore: _selectedNotifyTimes,
      focusMode: _isFocusMode,
      category: _selectedCategory!,
      userId: 'current_user_id', // Replace with actual user system
      type: _selectedTaskType,
    );

    try {
      final tasks = await StorageService.loadTasks();
      tasks.add(task);
      await StorageService.saveTasks(tasks);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Task บันทึกเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, task); // Return the created task
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สร้าง Task ใหม่'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton.icon(
            onPressed: _saveTask,
            icon: const Icon(Icons.save),
            label: const Text('บันทึก'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Task Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'ชื่อ Task *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'กรุณากรอกชื่อ Task'
                  : null,
            ),

            const SizedBox(height: 16),

            // Task Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'รายละเอียด (ไม่บังคับ)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // Task Type Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ประเภท Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<TaskType>(
                      segments: const [
                        ButtonSegment(
                          value: TaskType.even,
                          label: Text('กิจกรรม'),
                          icon: Icon(Icons.event),
                        ),
                        ButtonSegment(
                          value: TaskType.work,
                          label: Text('งาน'),
                          icon: Icon(Icons.work),
                        ),
                        ButtonSegment(
                          value: TaskType.birthday,
                          label: Text('วันเกิด'),
                          icon: Icon(Icons.cake),
                        ),
                      ],
                      selected: {_selectedTaskType},
                      onSelectionChanged: (Set<TaskType> newSelection) {
                        setState(() {
                          _selectedTaskType = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Date Selection
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('เลือกวันที่'),
                subtitle: Text(
                  DateFormat('EEEE, d MMMM yyyy', 'th').format(_selectedDate),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
            ),

            const SizedBox(height: 16),

            // All Day Toggle
            Card(
              child: SwitchListTile(
                title: const Text('ทั้งวัน'),
                subtitle: const Text('ไม่ต้องกำหนดเวลาเริ่มต้นและสิ้นสุด'),
                value: _isAllDay,
                onChanged: (val) => setState(() => _isAllDay = val),
                secondary: const Icon(Icons.all_inclusive),
              ),
            ),

            // Time Selection (only if not all day)
            if (!_isAllDay) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('เวลาเริ่ม'),
                        subtitle: Text(_startTime.format(context)),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _startTime,
                          );
                          if (time != null) setState(() => _startTime = time);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.access_time_filled),
                        title: const Text('เวลาสิ้นสุด'),
                        subtitle: Text(_endTime.format(context)),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _endTime,
                          );
                          if (time != null) setState(() => _endTime = time);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Category Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'หมวดหมู่',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      value: _selectedCategory,
                      hint: const Text('เลือกหมวดหมู่'),
                      items: _categories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _addNewCategoryDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('เพิ่มหมวดหมู่ใหม่'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Focus Mode Toggle
            Card(
              child: SwitchListTile(
                title: const Text('Focus Mode'),
                subtitle: const Text('เปิดโหมดโฟกัสเพื่อลดการรบกวน'),
                value: _isFocusMode,
                onChanged: (val) => setState(() => _isFocusMode = val),
                secondary: const Icon(Icons.psychology),
              ),
            ),

            const SizedBox(height: 16),

            // Notification Settings
            _buildNotificationSelector(),

            const SizedBox(height: 24),

            // Save Button
            ElevatedButton.icon(
              onPressed: _saveTask,
              icon: const Icon(Icons.save),
              label: const Text('บันทึก Task'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
