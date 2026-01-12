import 'package:flutter/material.dart';

class Taskname extends StatefulWidget {
  const Taskname({super.key, required this.mode, required this.onNameChanged});

  final bool mode;
  final Function(String) onNameChanged;

  @override
  _TasknameState createState() => _TasknameState();
}

class _TasknameState extends State<Taskname> {
  List<String> titles = ['Youtube', 'Novel'];
  String? selectedTitle;
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child : DropdownButtonFormField<String>(
        value: selectedTitle,
        isExpanded: true,
        dropdownColor: Colors.black,
        alignment: Alignment.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
        items: [
          ...titles.map((t) => DropdownMenuItem(
            value: t, 
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(t),
              ),
            )
          )),
          const DropdownMenuItem(
            value: 'add_new', 
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: Text('+')),
              ),
            )
        ],
        onChanged: (value) {
          if (value == 'add_new') {
            _showAddDialog(context);
            setState(() => selectedTitle = value);
          } else {
            setState(() => selectedTitle = value);
          }
          widget.onNameChanged(selectedTitle ?? '');
        },
      )
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
