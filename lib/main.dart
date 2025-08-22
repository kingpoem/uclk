import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '无限计时器',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TimerPage(),
    );
  }
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int _seconds = 0;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel(); // 避免重复启动
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 页面销毁时停止定时器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _seconds ~/ 3600;
    final minutes = (_seconds % 3600) ~/ 60;
    final secs = _seconds % 60;

    return Scaffold(
      appBar: AppBar(title: const Text("无限计时器")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${hours.toString().padLeft(2, '0')}:"
              "${minutes.toString().padLeft(2, '0')}:"
              "${secs.toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: _startTimer, child: const Text("开始")),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _stopTimer, child: const Text("暂停")),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _resetTimer, child: const Text("重置")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
