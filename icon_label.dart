
import 'package:flutter/material.dart';

class IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const IconLabel({super.key, required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    return LayoutBuilder(builder: (context, constraints) {
      // Allow label to wrap or ellipsize depending on available width.
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth > 0 ? constraints.maxWidth - 22 : double.infinity),
              child: Text(label, style: textStyle?.copyWith(color: color), overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
        ],
      );
    });
  }
}
