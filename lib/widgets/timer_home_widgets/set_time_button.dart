import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SetTimeButton extends StatefulWidget {
  const SetTimeButton({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final Function(bool, Duration) onChanged;
  final bool mode;

  @override
  State<SetTimeButton> createState() => _SetTimeButtonState();
}

class _SetTimeButtonState extends State<SetTimeButton> {
  late Duration _value = const Duration(hours: 0, minutes: 0);

  String get hh => _value.inHours.toString().padLeft(2, '0');
  String get mm => (_value.inMinutes % 60).toString().padLeft(2, '0');

  void _openPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        int tempHour = _value.inHours;
        int tempMin  = _value.inMinutes % 60; // 0 or 30

        final hours = List.generate(24, (i) => i.toString().padLeft(2, '0'));
        final minutes = const ['00', '30'];

        return CupertinoTheme(
          data: const CupertinoThemeData(brightness: Brightness.dark),
          child: SafeArea(
            top: false,
            child: Container(
              height: 300,
              color: Colors.black,
              child: Column(
                children: [
                  // 상단 액션바
                  SizedBox(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          onPressed: () => Navigator.pop(ctx), // 모달 닫기
                          child: const Text('취소'),
                        ),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          onPressed: () async {
                            // ✅ 확인 다이얼로그
                            final confirmed = await showCupertinoDialog<bool>(
                              context: ctx,
                              barrierDismissible: false,
                              builder: (_) => CupertinoAlertDialog(
                                title: Text('${widget.mode ? "공격" : "방어"} 시간 확정'),
                                content: Text(
                                  '이 시간으로 설정할까요?\n$tempHour시간 $tempMin분',
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('아니오'),
                                  ),
                                  CupertinoDialogAction(
                                    isDestructiveAction: false,
                                    isDefaultAction: true,
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('예'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              // 값 적용
                              setState(() => _value =
                                  Duration(hours: tempHour, minutes: tempMin));

                              widget.onChanged(widget.mode, _value);
                              // 확인 후 피커 모달 닫기
                              Navigator.pop(ctx);
                            }
                            // 취소면 아무 것도 안 하고 피커에 남아있음
                          },
                          child: const Text('완료'),
                        ),
                      ],
                    ),
                  ),
                  // 커스텀 시/분 휠
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 시(hour) - 루프 끔
                        SizedBox(
                          width: 100,
                          child: CupertinoPicker(
                            itemExtent: 32,
                            useMagnifier: true,
                            magnification: 1.08,
                            squeeze: 1.15,
                            looping: false,
                            scrollController: FixedExtentScrollController(
                              initialItem: tempHour,
                            ),
                            onSelectedItemChanged: (idx) => tempHour = idx,
                            children: hours.map((h) => Center(child: Text(h))).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 콜론은 텍스트 대신 컨테이너로 (의도치 않은 하이라이트 방지)
                        Container(width: 4, height: 2, color: Colors.white70),
                        const SizedBox(width: 8),
                        // 분(minute) - 00/30, 루프 끔
                        SizedBox(
                          width: 100,
                          child: CupertinoPicker(
                            itemExtent: 32,
                            useMagnifier: true,
                            magnification: 1.08,
                            squeeze: 1.15,
                            looping: false,
                            scrollController: FixedExtentScrollController(
                              initialItem: tempMin == 30 ? 1 : 0,
                            ),
                            onSelectedItemChanged: (idx) =>
                                tempMin = (idx == 1) ? 30 : 0,
                            children: minutes.map((m) => Center(child: Text(m))).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: _openPicker,
        child: Text("SET", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    );
  }
}
