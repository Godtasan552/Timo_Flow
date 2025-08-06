import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/tasks_model.dart';
import '../controllers/task_controller.dart';
import '../controllers/auth_controller.dart';

class CreatTaskPage extends StatefulWidget {
  final TaskType? initialType;
  const CreatTaskPage({super.key, this.initialType});

  @override
  State<CreatTaskPage> createState() => _CreatTaskPageState();
}

class _CreatTaskPageState extends State<CreatTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TaskType? _selectedType;
  bool _isAllDay = false;
  bool _focusMode = false;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int _notifyBefore = 5;
  DateTime? _selectedDate;
  final _categoryController = TextEditingController();
  String _category = 'even';

  final TaskController _taskController = Get.find();
  final authController = Get.find<AuthController>();
  String? userId;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? TaskType.even;
    _selectedDate = DateTime.now();
    _category = _selectedType?.name ?? 'even';
    userId = authController.currentUser.value?.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  // ตรวจสอบความถูกต้องของเวลา
  String? _validateTimeRange() {
    if (_startTime != null && _endTime != null && !_isAllDay) {
      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

      if (startMinutes >= endMinutes) {
        return 'End time must be after start time';
      }
    }
    return null;
  }

  // ตรวจสอบ Focus Mode
  String? _validateFocusMode() {
    if (_focusMode && (_startTime == null || _endTime == null)) {
      return 'Focus Mode requires both start and end time';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // เลือกโหมด
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: TaskType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.name),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = type;
                        _category = type.name;
                        // ถ้าไม่ใช่ goal ให้ปิด focus mode
                        if (_selectedType != TaskType.goal) {
                          _focusMode = false;
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // ชื่อ Task
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'กรุณากรอกชื่อ Task' : null,
              ),
              const SizedBox(height: 16),

              // วันที่
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: const OutlineInputBorder(),
                  hintText: _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select date',
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                validator: (v) =>
                    _selectedDate == null ? 'กรุณาเลือกวันที่' : null,
              ),
              const SizedBox(height: 16),

              // เวลาเริ่ม/จบ
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: _startTime != null
                            ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                            : '',
                      ),
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        border: const OutlineInputBorder(),
                        hintText: 'Select time',
                        suffixIcon: const Icon(Icons.access_time),
                        enabled: !_isAllDay, // ปิดการใช้งานถ้าเป็น All Day
                      ),
                      onTap: !_isAllDay
                          ? () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _startTime ?? TimeOfDay.now(),
                              );
                              if (picked != null) {
                                setState(() => _startTime = picked);
                              }
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: _endTime != null
                            ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                            : '',
                      ),
                      decoration: InputDecoration(
                        labelText: 'End Time',
                        border: const OutlineInputBorder(),
                        hintText: 'Select time',
                        suffixIcon: const Icon(Icons.access_time),
                        enabled: !_isAllDay, // ปิดการใช้งานถ้าเป็น All Day
                      ),
                      onTap: !_isAllDay
                          ? () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _endTime ?? TimeOfDay.now(),
                              );
                              if (picked != null) {
                                setState(() => _endTime = picked);
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // แสดง error message สำหรับเวลา
              if (_validateTimeRange() != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _validateTimeRange()!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),

              // All Day & Focus Mode
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('All Day'),
                      subtitle: const Text('Task runs for the entire day'),
                      value: _isAllDay,
                      onChanged: (val) {
                        setState(() {
                          _isAllDay = val;
                          if (_isAllDay) {
                            _focusMode = false;
                            _startTime = null;
                            _endTime = null;
                          }
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Focus Mode'),
                      subtitle: Text(
                        _selectedType == TaskType.goal
                            ? 'Timer-based focus session'
                            : 'Only available for Goal tasks',
                      ),
                      value: _focusMode,
                      onChanged: (_selectedType == TaskType.goal && !_isAllDay)
                          ? (val) {
                              setState(() {
                                _focusMode = val;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // แสดง error message สำหรับ Focus Mode
              if (_validateFocusMode() != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _validateFocusMode()!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),

              // แจ้งเตือนก่อนเวลา
              DropdownButtonFormField<int>(
                value: _notifyBefore,
                decoration: const InputDecoration(
                  labelText: 'แจ้งเตือนก่อนเวลา',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('ไม่แจ้งเตือน')),
                  DropdownMenuItem(value: 5, child: Text('5 นาที')),
                  DropdownMenuItem(value: 10, child: Text('10 นาที')),
                  DropdownMenuItem(value: 15, child: Text('15 นาที')),
                  DropdownMenuItem(value: 30, child: Text('30 นาที')),
                  DropdownMenuItem(value: 60, child: Text('1 ชั่วโมง')),
                  DropdownMenuItem(value: 1440, child: Text('1 วัน')),
                  DropdownMenuItem(value: 10080, child: Text('1 สัปดาห์')),
                ],
                onChanged: (val) => setState(() => _notifyBefore = val ?? 5),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText: 'Enter task description (optional)',
                ),
                maxLines: 3,
                maxLength: 500, // จำกัดความยาว
              ),
              const SizedBox(height: 16),

              // Category (แสดงเป็น info เท่านั้น)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.category),
                      const SizedBox(width: 8),
                      const Text('Category: '),
                      Chip(
                        label: Text(_category),
                        backgroundColor: _selectedType == TaskType.birthday
                            ? Colors.blue[100]
                            : _selectedType == TaskType.even
                            ? Colors.pink[100]
                            : Colors.purple[100],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ปุ่มสร้าง Task
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_task),
                  label: const Text('Create Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    // ตรวจสอบ validation
                    if (!_formKey.currentState!.validate()) return;

                    // ตรวจสอบเวลา
                    final timeError = _validateTimeRange();
                    if (timeError != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(timeError)));
                      return;
                    }

                    // ตรวจสอบ Focus Mode
                    final focusError = _validateFocusMode();
                    if (focusError != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(focusError)));
                      return;
                    }

                    // ตรวจสอบ userId
                    if (userId == null || userId!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not logged in')),
                      );
                      return;
                    }

                    try {
                      final task = Task(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: userId!,
                        title: _titleController.text.trim(),
                        description: _descController.text.trim().isEmpty
                            ? null
                            : _descController.text.trim(),
                        category: _category,
                        date: _selectedDate!,
                        startTime: _isAllDay ? null : _startTime,
                        endTime: _isAllDay ? null : _endTime,
                        isAllDay: _isAllDay,
                        notifyBefore: _notifyBefore > 0 ? [_notifyBefore] : [],
                        focusMode: _focusMode,
                        isDone: false,
                        type: _selectedType!,
                      );

                      await _taskController.addTask(task);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Task created successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (error) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error creating task: $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
