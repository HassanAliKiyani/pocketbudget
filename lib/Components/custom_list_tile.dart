import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    required this.title,
    required this.trailing,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  final String title;
  final String trailing;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Slidable(
        endActionPane: ActionPane(motion: const StretchMotion(), children: [
          SlidableAction(
            onPressed: onEditPressed,
            icon: Icons.edit,
            backgroundColor: Colors.grey,
            padding: const EdgeInsets.all(16.0),
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          SlidableAction(
            onPressed: onDeletePressed,
            icon: Icons.delete,
            backgroundColor: Colors.red,
            padding: const EdgeInsets.all(16.0),
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ]),
        child: Container(
          decoration: BoxDecoration(
              // color: Colors.grey.shade600pr,
              color: Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(4.0)),
          child: ListTile(
            title: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            trailing: Text(
              trailing,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
