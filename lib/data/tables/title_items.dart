import 'package:drift/drift.dart';

class TitleItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  // 예: "video", "book" 같은 카테고리 키
  TextColumn get type => text()();

  // 예: "Youtube", "Novel" 같은 타이틀
  TextColumn get title => text()();

  // 선택: 정렬 필요하면
  IntColumn get sort => integer().withDefault(const Constant(0))();

  // 중복 방지(같은 type 안에 같은 title 2개 금지)
  @override
  List<Set<Column>> get uniqueKeys => [
    {type, title},
  ];
}
