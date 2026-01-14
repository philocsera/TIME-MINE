import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int _selected1 = 0;
  int _selected2 = 0;


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: CupertinoSegmentedControl<int>(
              groupValue: _selected1,
              children: const {
                0: Text('Daily'),
                1: Text('Weekly'),
                2: Text('Monthly'),
                3: Text('Total'),
              },
              onValueChanged: (value) {
                setState(() => _selected1 = value);
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: CupertinoSegmentedControl<int>(
              groupValue: _selected2,
              children: const {
                0: Text('Attack'),
                1: Text('Defense'),
                2: Text('Total'),
              },
              onValueChanged: (value) {
                setState(() => _selected2 = value);
              },
            ),
          ),
        ],
      ),
    );
  }
}