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
  final List<String> _categories = ['Work', 'Personal', 'Health', 'Study', 'even', 'goal', 'birthday', 'other'];
  late TextEditingController _categoryController;

  final TaskController _taskController = Get.find();

  // Color scheme
  static const Color primaryPastel = Color(0xFFE8D5FF);
  static const Color secondaryPastel = Color(0xFFFFE4E6);
  static const Color backgroundPastel = Color(0xFFF8F6FF);
  static const Color cardPastel = Color(0xFFFFFBFF);

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

    if (!_categories.contains(_category)) {
      _categories.add(_category);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B4EFF),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardPastel,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPastel,
      appBar: AppBar(
        title: const Text(
          'Edit Task',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B4EFF),
          ),
        ),
        backgroundColor: primaryPastel,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF6B4EFF)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Type Selection
              _buildSectionTitle('Task Type'),
              _buildCard(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TaskType.values.map((type) {
                    final isSelected = _selectedType == type;
                    Color bgColor;
                    Color textColor;
                    
                    switch (type) {
                      case TaskType.even:
                        bgColor = isSelected ? const Color(0xFFFFB3D1) : const Color(0xFFFFF0F5);
                        textColor = const Color(0xFFD81B60);
                        break;
                      case TaskType.goal:
                        bgColor = isSelected ? const Color(0xFFB3E5FC) : const Color(0xFFF0F8FF);
                        textColor = const Color(0xFF0288D1);
                        break;
                      case TaskType.birthday:
                        bgColor = isSelected ? const Color(0xFFCE93D8) : const Color(0xFFF3E5F5);
                        textColor = const Color(0xFF8E24AA);
                        break;
                    }

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedType = type;
                          _category = type.name;
                          if (_selectedType != TaskType.goal) _focusMode = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(25),
                          border: isSelected 
                            ? Border.all(color: textColor, width: 2)
                            : null,
                        ),
                        child: Text(
                          type.name.toUpperCase(),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 24),

              // Task Details
              _buildSectionTitle('Task Details'),
              _buildCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Task Name',
                        labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6B4EFF), width: 2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Please enter task name' : null,
                    ),
                    
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6B4EFF), width: 2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Date & Time
              _buildSectionTitle('Date & Time'),
              _buildCard(
                child: Column(
                  children: [
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6B4EFF), width: 2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        hintText: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF6B4EFF)),
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
                    ),
                    
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Start Time',
                              labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF6B4EFF), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFAFAFA),
                              hintText: _startTime != null
                                  ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Select time',
                              suffixIcon: const Icon(Icons.access_time, color: Color(0xFF6B4EFF)),
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'End Time',
                              labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF6B4EFF), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFAFAFA),
                              hintText: _endTime != null
                                  ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Select time',
                              suffixIcon: const Icon(Icons.access_time, color: Color(0xFF6B4EFF)),
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

                    if (_validateTimeRange() != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _validateTimeRange()!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Settings
              _buildSectionTitle('Settings'),
              _buildCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F8FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'All Day',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: const Text(
                          'Task runs for the entire day',
                          style: TextStyle(color: Color(0xFF757575)),
                        ),
                        value: _isAllDay,
                        activeColor: const Color(0xFF6B4EFF),
                        onChanged: (val) {
                          setState(() {
                            _isAllDay = val;
                            if (_isAllDay) _focusMode = false;
                          });
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: _selectedType == TaskType.goal && !_isAllDay 
                          ? const Color(0xFFF0F8FF) 
                          : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'Focus Mode',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          _selectedType == TaskType.goal
                              ? 'Timer-based focus session'
                              : 'Only available for Goal tasks',
                          style: TextStyle(
                            color: _selectedType == TaskType.goal && !_isAllDay 
                              ? const Color(0xFF757575) 
                              : Colors.grey,
                          ),
                        ),
                        value: _focusMode,
                        activeColor: const Color(0xFF6B4EFF),
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
              ),

              const SizedBox(height: 24),

              // Notification & Category
              _buildSectionTitle('Additional Settings'),
              _buildCard(
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      value: _notifyBefore,
                      decoration: InputDecoration(
                        labelText: 'Notify Before',
                        labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6B4EFF), width: 2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                      ),
                      items: const [
                        DropdownMenuItem(value: 5, child: Text('5 minutes')),
                        DropdownMenuItem(value: 10, child: Text('10 minutes')),
                        DropdownMenuItem(value: 15, child: Text('15 minutes')),
                        DropdownMenuItem(value: 30, child: Text('30 minutes')),
                        DropdownMenuItem(value: 60, child: Text('1 hour')),
                        DropdownMenuItem(value: 1440, child: Text('1 day')),
                        DropdownMenuItem(value: 10080, child: Text('1 week')),
                      ],
                      onChanged: (val) => setState(() => _notifyBefore = val ?? 5),
                    ),
                    
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6B4EFF), width: 2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                      ),
                      isExpanded: true,
                      items: _categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) => setState(() => _category = val ?? 'other'),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Please select category' : null,
                      menuMaxHeight: 200,
                    ),
                    
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _categoryController,
                            decoration: InputDecoration(
                              labelText: 'Add New Category',
                              labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF6B4EFF), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFAFAFA),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 56,
                          child: ElevatedButton(
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B4EFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Changes Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, size: 20),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4EFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final timeError = _validateTimeRange();
                    if (timeError != null) {
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.error(message: timeError),
                      );
                      return;
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

                      await Future.delayed(const Duration(milliseconds: 800));
                      if (mounted) Navigator.pop(context);
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}