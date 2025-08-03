import 'package:flutter/material.dart';
import '../model/tasks_model.dart';

class CreatTaskPage extends StatefulWidget {
  final TaskType? initialType;
  const CreatTaskPage({super.key, this.initialType});

  @override
  State<CreatTaskPage> createState() => _CreatTaskPageState();
}

class _CreatTaskPageState extends State<CreatTaskPage> {
  TaskType? _selectedType;
  bool _isAllDay = false;
  bool _focusMode = false;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int _notifyBefore = 5;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? TaskType.even;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                    setState(() => _selectedType = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // ชื่อ Task
            TextFormField(
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            const SizedBox(height: 16),
            // วันที่
            TextFormField(
              decoration: const InputDecoration(labelText: 'Date'),
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                // setState(() { ... });
              },
            ),
            const SizedBox(height: 16),
            // เวลาเริ่ม/จบ
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Start Time'),
                    readOnly: true,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      setState(() => _startTime = picked);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'End Time'),
                    readOnly: true,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      setState(() => _endTime = picked);
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
                    onChanged: (_selectedType == TaskType.work)
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
              decoration: const InputDecoration(labelText: 'แจ้งเตือนก่อนเวลา'),
            ),
            const SizedBox(height: 16),
            // Description
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            // Category
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('even')),
                Chip(label: Text('work')),
                Chip(label: Text('birthday')),
                Chip(label: Text('goal')),
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
                onPressed: () {
                  // สร้าง task และบันทึก
                },
                child: const Text('Create Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}