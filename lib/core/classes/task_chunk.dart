class TaskChunk {
  late String taskName;
  late DateTime startAt;
  late DateTime endAt;

  void setTaskName(String name) => taskName = name;
  void setStartAt(DateTime start) => startAt = start;
  void setEndAt(DateTime end) => endAt = end;

  Duration get duration => endAt.difference(startAt);
}