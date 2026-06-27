import 'package:timemine/core/core.dart';

class TitlePickerPage extends StatefulWidget {
  const TitlePickerPage({
    super.key,
    required this.mode,
    required this.titles,
    required this.initialSelected,
  });

  final bool mode;
  final List<String> titles; // 부모에서 받은 "원본 리스트" (공유됨)
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
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white12,
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
                itemCount: _filteredTitles.length + 1, // + Add new row
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(Icons.check, color: Colors.white),
                          ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.white.withOpacity(0.85),
                          ),
                          onPressed: () => _confirmDelete(context, t),
                        ),
                      ],
                    ),
                    // ✅ 선택했을 때만 페이지 닫고 타이머로 돌아감
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
            hintStyle: TextStyle(color: Colors.white54),
          ),
          onSubmitted: (_) => Navigator.pop(ctx, _addController.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, _addController.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == null) return;
    final newTitle = result.trim();
    if (newTitle.isEmpty) return;

    // ✅ 1) DB에 저장 (중복은 insertOrIgnore라 안전)
    final db = context.read<AppDB>();
    await db.addTitle(widget.mode ? 'attack' : 'defense', newTitle);

    // ✅ 2) UI 목록도 갱신: (A) 메모리 추가 or (B) DB에서 재로드
    if (!widget.titles.contains(newTitle)) {
      widget.titles.add(newTitle);
    }

    if (!mounted) return;
    setState(() {});
  }


  Future<void> _confirmDelete(BuildContext context, String title) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Delete title?', style: TextStyle(color: Colors.white)),
        content: Text(
          '"$title" will be removed.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    // ✅ 1) DB에서도 삭제
    final db = context.read<AppDB>();
    final type = widget.mode ? 'attack' : 'defense'; // 너 구조에 맞게 type 가져오면 됨
    await db.deleteTitle(type, title);

    // ✅ 2) UI 목록에서도 제거 (즉시 반영)
    widget.titles.remove(title);

    if (!mounted) return;
    setState(() {});

    // ✅ 3) 선택된 걸 삭제했다면 선택 해제 + 닫기
    if (title == widget.initialSelected) {
      Navigator.pop(context, null);
    }
  }
}
