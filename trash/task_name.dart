import 'package:flutter/material.dart';
import 'package:timemine/widgets/timer_home_widgets/title_picker.dart';

class Taskname extends StatefulWidget {
  const Taskname({
    super.key,
    required this.mode,
    required this.onNameChanged,
    required this.titles,
  });

  final bool mode;
  final Function(String) onNameChanged;
  final List<String> titles;

  @override
  TasknameState createState() => TasknameState();
}

class TasknameState extends State<Taskname> {
  String? selectedTitle;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.6;

    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final picked = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (_) => TitlePickerPage(
                mode: widget.mode,
                titles: widget.titles,
                initialSelected: selectedTitle,
              ),
            ),
          );

          if (picked == null) return;

          setState(() => selectedTitle = picked);
          widget.onNameChanged(picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.label_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  selectedTitle ?? 'Select Title',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}