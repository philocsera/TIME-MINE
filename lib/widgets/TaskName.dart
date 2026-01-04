import 'package:flutter/material.dart';

class Taskname extends StatefulWidget {
  const Taskname({super.key});

  @override
  _TasknameState createState() => _TasknameState();
}

class _TasknameState extends State<Taskname> {
  List<String> titles = ['A', 'B', 'C'];
  String? selectedTitle;
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DropdownButtonFormField<String>(
          value: selectedTitle,
          items: [
            ...titles.map((t) => DropdownMenuItem(value: t, child: Text(t))),
            const DropdownMenuItem(value: 'add_new', child: Text('+')),
          ],
          onChanged: (value) {
            if (value == 'add_new') {
              _showAddDialog(context);
              setState(() => selectedTitle = value);
            } else {
              setState(() => selectedTitle = value);
            }
          },
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                setState(() {
                  titles.add(_controller.text);
                  selectedTitle = _controller.text;
                });
              }
              _controller.clear();
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
