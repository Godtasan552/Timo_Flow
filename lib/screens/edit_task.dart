import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/tasks_model.dart';
import '../controllers/task_controller.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;
  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TaskType _selectedType;
  late bool _isAllDay;
  late bool _focusMode;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late int _notifyBefore;
  late DateTime _selectedDate;
  late String _category;
  final List<String> _categories = ['even', 'goal', 'birthday', 'other'];
  late TextEditingController _categoryController;

  final TaskController _taskController = Get.find();

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController = TextEditingController(text: t.title);
    _descController = TextEditingController(text: t.description ?? '');
    _selectedType = t.type;
    _isAllDay = t.isAllDay;
    _focusMode = t.focusMode;
    _startTime = t.startTime;
    _endTime = t.endTime;
    _notifyBefore = t.notifyBefore.isNotEmpty ? t.notifyBefore.first : 5;
    _selectedDate = t.date;
    _category = t.category;
    _categoryController = TextEditingController();

    // ถ้า category เดิมไม่อยู่ใน default list ให้เพิ่ม
    if (!_categories.contains(_category)) {
      _categories.add(_category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'กรุณากรอกชื่อ Task' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  hintText:
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                // No need to validate _selectedDate for null
              ),
              const SizedBox(height: 16),
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
                          initialTime: _startTime ?? TimeOfDay.now(),
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
                          initialTime: _endTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) setState(() => _endTime = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) => setState(() => _category = val ?? 'other'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'กรุณาเลือกหมวดหมู่' : null,
                menuMaxHeight: 200,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'เพิ่ม Category ใหม่',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final newCat = _categoryController.text.trim();
                      if (newCat.isNotEmpty && !_categories.contains(newCat)) {
                        setState(() {
                          _categories.add(newCat);
                          _category = newCat;
                          _categoryController.clear();
                        });
                      }
                    },
                    child: const Text('เพิ่ม'),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    // ตรวจสอบเวลาว่า startTime < endTime (ถ้าไม่ได้เลือก All Day)
                    if (!_isAllDay && _startTime != null && _endTime != null) {
                      final startMinutes =
                          _startTime!.hour * 60 + _startTime!.minute;
                      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
                      if (startMinutes >= endMinutes) {
                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.error(
                            message: 'End time must be after start time',
                          ),
                        );
                        return;
                      }
                    }

                    final updatedTask = Task(
                      id: widget.task.id,
                      userId: widget.task.userId,
                      title: _titleController.text.trim(),
                      description: _descController.text.trim(),
                      category: _category,
                      date: _selectedDate,
                      startTime: _startTime,
                      endTime: _endTime,
                      isAllDay: _isAllDay,
                      notifyBefore: [_notifyBefore],
                      focusMode: _focusMode,
                      isDone: widget.task.isDone,
                      type: _selectedType,
                    );

                    await _taskController.updateTask(updatedTask);

                    if (mounted) {
                      showTopSnackBar(
                        Overlay.of(context),
                        const CustomSnackBar.success(
                          message: 'Task updated successfully',
                        ),
                      );

                      // รอสักครู่ก่อนปิดหน้า
                      await Future.delayed(const Duration(milliseconds: 800));
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
