import 'package:flutter/material.dart';
import 'widgets/task_card.dart';

void main() => runApp(const TaskApp());

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Fundamentals Demo',
      theme: ThemeData(useMaterial3: true),
      home: const TaskListPage(),
    );
  }
}

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final List<Map<String, Object?>> _tasks = [
    {
      'title': 'Plan sprint goals',
      'description': 'Draft sprint goals, align with PM and engineering leads.',
      'priority': 'High',
      'dueDate': 'Today',
      'assignee': 'Alex',
      'createdAt': null,
    },
    {
      'title': 'Code review backlog',
      'description': 'Work through the oldest PRs and leave focused feedback.',
      'priority': 'Low',
      'dueDate': 'Thu',
      'assignee': 'You',
      'createdAt': null,
    },
    {
      'title': 'Design review prep',
      'description': 'Prepare mockups and notes for the design review.',
      'priority': 'High',
      'dueDate': 'Fri',
      'assignee': 'Sam',
      'createdAt': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Tasks'))),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final t = _tasks[i];
          // Render the first item as expandable for demo parity
          final widgetItem = i == 0
              ? ExpandableTaskCard(
                  title: t['title'] as String,
                  description: t['description'] as String,
                  priority: t['priority'] as String,
                  dueDate: t['dueDate'] as String?,
                  assignee: t['assignee'] as String?,
                )
              : TaskListItem(
                  title: t['title'] as String,
                  description: t['description'] as String,
                  priority: t['priority'] as String,
                  dueDate: t['dueDate'] as String?,
                  assignee: t['assignee'] as String?,
                );

          // Show createdAt / dueDate by wrapping with Column
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            widgetItem,
            const SizedBox(height: 4),
            if (t['createdAt'] != null) Text('Created: ${t['createdAt']}'),
            if (t['dueDate'] != null && t['createdAt'] == null) Text('Due: ${t['dueDate']}'),
          ]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openAddModal(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, Object?>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String selectedPriority = 'Medium';
        final titleController = TextEditingController(text: '');
        final descController = TextEditingController();
        DateTime? pickedDate;
        TimeOfDay? pickedTime;

        Future<void> _pickDate(BuildContext innerContext, StateSetter setState) async {
          final now = DateTime.now();
          final d = await showDatePicker(context: innerContext, initialDate: now, firstDate: now.subtract(const Duration(days: 365)), lastDate: now.add(const Duration(days: 365)));
          if (d != null) setState(() => pickedDate = d);
        }

        Future<void> _pickTime(BuildContext innerContext, StateSetter setState) async {
          final t = await showTimePicker(context: innerContext, initialTime: TimeOfDay.now());
          if (t != null) setState(() => pickedTime = t);
        }

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Add Task', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                    const SizedBox(height: 8),
                    TextField(controller: descController, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
                    const SizedBox(height: 12),
                    Row(children: [
                      const Text('Priority: '),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: selectedPriority,
                        items: ['High', 'Medium', 'Low'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                        onChanged: (v) => setState(() => selectedPriority = v ?? 'Medium'),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _pickDate(context, setState);
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(pickedDate == null ? 'Pick date' : pickedDate!.toLocal().toString().split(' ')[0]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _pickTime(context, setState);
                          },
                          icon: const Icon(Icons.access_time),
                          label: Text(pickedTime == null ? 'Pick time' : pickedTime!.format(context)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: ElevatedButton(onPressed: () {
                        // Create the task and return it to the parent
                        final createdAt = DateTime.now();
                        final dueText = pickedDate != null ? '${pickedDate!.toLocal().toString().split(' ')[0]}${pickedTime != null ? ' ${pickedTime!.format(context)}' : ''}' : null;
                        final newTask = {
                          'title': titleController.text,
                          'description': descController.text,
                          'priority': selectedPriority,
                          'dueDate': dueText,
                          'assignee': 'You',
                          'createdAt': createdAt.toLocal().toString(),
                        };
                        Navigator.pop(context, newTask);
                      }, child: const Text('Create'))),
                    ]),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );

    if (result != null) {
      setState(() {
        _tasks.insert(0, result);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task created')));
    }
  }
}
