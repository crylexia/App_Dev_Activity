
import 'package:flutter/material.dart';
import 'icon_label.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String priority;
  final String? dueDate;
  final String? assignee;
  final Widget? trailing;
  final VoidCallback? onTap;

  const TaskCard({
    Key? key,
    required this.title,
    required this.description,
    required this.priority,
    this.dueDate,
    this.assignee,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final priorityColor = priority.toLowerCase() == 'high' ? Colors.red : Colors.green;

    Widget content = Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;
          return isNarrow
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
                    const SizedBox(width: 12),
                    _PriorityBadge(priority: priority, color: priorityColor),
                  ]),
                  const SizedBox(height: 8),
                  Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Wrap(spacing: 12, children: [
                    IconLabel(icon: Icons.comment, label: '2 comments'),
                    IconLabel(icon: Icons.person, label: assignee ?? 'Unassigned'),
                    if (trailing != null) trailing!,
                  ])
                ])
              : Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    _PriorityBadge(priority: priority, color: priorityColor),
                    const SizedBox(height: 8),
                    IconLabel(icon: Icons.person, label: assignee ?? 'Unassigned'),
                    if (trailing != null) ...[const SizedBox(height: 8), trailing!],
                  ])
                ]);
        }),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;
  final Color color;
  const _PriorityBadge({required this.priority, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(priority, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

class ExpandableTaskCard extends StatefulWidget {
  final String title;
  final String description;
  final String priority;
  final String? dueDate;
  final String? assignee;
  final Widget? trailing;
  final VoidCallback? onTap;
  const ExpandableTaskCard({Key? key, required this.title, required this.description, required this.priority, this.dueDate, this.assignee, this.trailing, this.onTap}) : super(key: key);

  @override
  State<ExpandableTaskCard> createState() => _ExpandableTaskCardState();
}

class _ExpandableTaskCardState extends State<ExpandableTaskCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final priorityColor = widget.priority.toLowerCase() == 'high'
        ? Colors.red
        : widget.priority.toLowerCase() == 'medium'
            ? Colors.orange
            : Colors.green;
    Widget card = InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
                  const SizedBox(width: 12),
                  _PriorityBadge(priority: widget.priority, color: priorityColor),
                  if (widget.trailing != null) ...[const SizedBox(width: 8), widget.trailing!],
                ]),
                const SizedBox(height: 8),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: isNarrow
                      ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(widget.description),
                          const SizedBox(height: 8),
                          Wrap(spacing: 12, children: [
                            IconLabel(icon: Icons.comment, label: '2 comments'),
                            IconLabel(icon: Icons.person, label: widget.assignee ?? 'Unassigned'),
                          ]),
                        ])
                      : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(widget.description),
                          const SizedBox(height: 8),
                          Row(children: [
                            IconLabel(icon: Icons.comment, label: '2 comments'),
                            const SizedBox(width: 12),
                            IconLabel(icon: Icons.person, label: widget.assignee ?? 'Unassigned'),
                          ])
                        ]),
                  crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            );
          }),
        ),
      ),
    );

    if (widget.onTap != null) {
      // Wrap card so navigation tap works (keeps internal expand tap for InkWell).
      return GestureDetector(onTap: widget.onTap, child: card);
    }
    return card;
  }
}

/// Wrapper used in the list to provide a local done-toggle and navigation.
class TaskListItem extends StatefulWidget {
  final String title;
  final String description;
  final String priority;
  final String? dueDate;
  final String? assignee;
  final bool expandable;
  const TaskListItem({Key? key, required this.title, required this.description, required this.priority, this.dueDate, this.assignee, this.expandable = false}) : super(key: key);

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {
  bool _done = false;

  void _toggleDone() => setState(() => _done = !_done);

  void _openDetail() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _TaskDetailPage(
      title: widget.title,
      description: widget.description,
      priority: widget.priority,
      dueDate: widget.dueDate,
      assignee: widget.assignee,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final trailing = IconButton(
      icon: Icon(_done ? Icons.check_circle : Icons.radio_button_unchecked, color: _done ? Colors.green : Colors.grey),
      onPressed: _toggleDone,
      tooltip: _done ? 'Done' : 'Mark done',
    );

    if (widget.expandable) {
      return ExpandableTaskCard(
        title: widget.title,
        description: widget.description,
        priority: widget.priority,
        dueDate: widget.dueDate,
        assignee: widget.assignee,
        trailing: trailing,
        onTap: _openDetail,
      );
    }

    return TaskCard(
      title: widget.title,
      description: widget.description,
      priority: widget.priority,
      dueDate: widget.dueDate,
      assignee: widget.assignee,
      trailing: trailing,
      onTap: _openDetail,
    );
  }
}

class _TaskDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String priority;
  final String? dueDate;
  final String? assignee;
  const _TaskDetailPage({Key? key, required this.title, required this.description, required this.priority, this.dueDate, this.assignee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Priority: $priority'),
          if (dueDate != null) ...[const SizedBox(height: 8), Text('Due: $dueDate')],
          if (assignee != null) ...[const SizedBox(height: 8), Text('Assignee: $assignee')],
          const SizedBox(height: 16),
          Text(description),
        ]),
      ),
    );
  }
}

