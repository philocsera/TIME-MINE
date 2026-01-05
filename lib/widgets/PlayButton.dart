import 'package:flutter/material.dart';

class PlayButton extends StatefulWidget {
  const PlayButton({super.key});

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  @override
  Widget build(BuildContext context){
    return Center(
        child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        fixedSize: const Size(400, 400), // 고정 크기 설정
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Image.asset('../assets/play_button.png')
      ))
    );
  }
}