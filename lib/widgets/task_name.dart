import 'package:flutter/material.dart';

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

class TitlePickerPage extends StatefulWidget {
  const TitlePickerPage({
    super.key,
    required this.mode,
    required this.titles,
    required this.initialSelected,
  });

  final bool mode;
  final List<String> titles;
  final String? initialSelected;

  @override
  State<TitlePickerPage> createState() => _TitlePickerPageState();
}

class _TitlePickerPageState extends State<TitlePickerPage> {
  late final TextEditingController _searchController;
  late final TextEditingController _addController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _addController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _addController.dispose();
    super.dispose();
  }

  List<String> get _filteredTitles {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return widget.titles;
    return widget.titles.where((t) => t.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.mode ? Colors.red : const Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Select Title'),
        actions: [
          IconButton(
            tooltip: 'Add new',
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  hintText: 'Search title',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.18)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: accent.withOpacity(0.9)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _filteredTitles.length + 1, // + "Add new" row
                separatorBuilder: (_, __) =>
                    Divider(color: Colors.white.withOpacity(0.10), height: 1),
                itemBuilder: (context, index) {
                  // 마지막 줄: + Add new
                  if (index == _filteredTitles.length) {
                    return ListTile(
                      leading: const Icon(Icons.add, color: Colors.white),
                      title: const Text(
                        'Add new',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      onTap: () => _showAddDialog(context),
                    );
                  }

                  final t = _filteredTitles[index];
                  final isSelected = t == widget.initialSelected;

                  return ListTile(
                    title: Text(
                      t,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                    onTap: () => Navigator.pop(context, t),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    _addController.clear();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Add new title', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _addController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Type title',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = _addController.text.trim();
              if (text.isEmpty) {
                Navigator.pop(ctx);
                return;
              }
              Navigator.pop(ctx, text);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == null) return;

    final newTitle = result.trim();
    if (newTitle.isEmpty) return;

    // ✅ 중요한 포인트:
    // widget.titles는 "부모로부터 받은 List"라서 여기서 add 하면 원본 리스트가 같이 바뀜.
    // (TasknameState의 titles 리스트를 그대로 넘겨주고 있어서)
    if (!widget.titles.contains(newTitle)) {
      widget.titles.add(newTitle);
    }

    // 추가하면 바로 선택해서 돌아가기
    if (mounted) {
      Navigator.pop(context, newTitle);
    }
  }
}
