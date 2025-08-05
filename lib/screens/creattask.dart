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
                        if (_selectedType != TaskType.goal) _focusMode = false;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // ชื่อ Task
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'กรุณากรอกชื่อ Task' : null,
              ),
              const SizedBox(height: 16),
              // วันที่
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  hintText: _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : '',
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
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        hintText: _startTime != null
                            ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                            : '',
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) setState(() => _startTime = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'End Time',
                        hintText: _endTime != null
                            ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                            : '',
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) setState(() => _endTime = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // All Day & Focus Mode
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('All Day'),
                      value: _isAllDay,
                      onChanged: (val) {
                        setState(() {
                          _isAllDay = val;
                          if (_isAllDay) _focusMode = false;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Focus Mode'),
                      value: _focusMode,
                      onChanged: (_selectedType == TaskType.goal)
                          ? (val) {
                              setState(() {
                                _focusMode = val;
                                if (_focusMode) _isAllDay = false;
                              });
                            }
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // แจ้งเตือนก่อนเวลา
              DropdownButtonFormField<int>(
                value: _notifyBefore,
                items: const [
                  DropdownMenuItem(value: 5, child: Text('5 นาที')),
                  DropdownMenuItem(value: 10, child: Text('10 นาที')),
                  DropdownMenuItem(value: 15, child: Text('15 นาที')),
                  DropdownMenuItem(value: 30, child: Text('30 นาที')),
                  DropdownMenuItem(value: 60, child: Text('1 ชั่วโมง')),
                  DropdownMenuItem(value: 1440, child: Text('1 วัน')),
                  DropdownMenuItem(value: 10080, child: Text('1 สัปดาห์')),
                ],
                onChanged: (val) => setState(() => _notifyBefore = val ?? 5),
                decoration: const InputDecoration(
                  labelText: 'แจ้งเตือนก่อนเวลา',
                ),
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // Category
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text('even')),
                  Chip(label: Text('goal')),
                  Chip(label: Text('birthday')),
                  ActionChip(
                    label: const Text('+ Add Category'),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // ปุ่มสร้าง Task
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    // TODO: ใส่ userId จริง
                    final task = Task(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: userId ?? '', // เปลี่ยนเป็น userId จริง
                      title: _titleController.text,
                      description: _descController.text,
                      category: _category,
                      date: _selectedDate!,
                      startTime: _startTime,
                      endTime: _endTime,
                      isAllDay: _isAllDay,
                      notifyBefore: [_notifyBefore],
                      focusMode: _focusMode,
                      isDone: false,
                      type: _selectedType!,
                    );
                    await _taskController.addTask(task);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Create Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
